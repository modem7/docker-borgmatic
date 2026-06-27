#!/bin/bash
# Optional custom init script — mount at /custom-cont-init.d/init-keepassxc-cli.sh
#
# Installs a lightweight keepassxc-cli shim using pykeepass (pure Python,
# no Qt/GUI dependencies) so borgmatic can retrieve credentials from a
# KeePass database.
#
# Also supports the secret-service backend via secretstorage + jeepney,
# which connects to the host's D-Bus session bus (mount required — see docs).
#
# File-based usage:
#   keepassxc:
#     database: /path/to/passwords.kdbx
#     ask_for_password: false
#     key_file: /run/secrets/keepass.keyx   # optional
#   encryption_passphrase: "{credential keepassxc /path/to/passwords.kdbx MyEntry}"
#
# Secret service usage (requires host D-Bus mount — see KEEPASSXC-CLI.md):
#   encryption_passphrase: "{credential keepassxc secret-service MyEntry}"

set -e

echo "[init-keepassxc-cli] Installing pykeepass and secretstorage..."
pip install --quiet --no-cache-dir pykeepass "secretstorage[jeepney]"

echo "[init-keepassxc-cli] Writing /usr/local/bin/keepassxc-cli shim..."
cat > /usr/local/bin/keepassxc-cli << 'SHIM'
#!/usr/bin/env python3
"""
Minimal keepassxc-cli shim backed by pykeepass (file-based) and
secretstorage/jeepney (secret-service backend via host D-Bus).

Implements the subset of keepassxc-cli that borgmatic calls:

  File-based:
    keepassxc-cli show --show-protected --attributes <attr>
                       [--no-password] [--key-file <file>]
                       <database> <entry>

  Secret service:
    keepassxc-cli show --secret-service <entry>
"""
import argparse
import sys


def lookup_file(args):
    try:
        from pykeepass import PyKeePass
        from pykeepass.exceptions import CredentialsError
    except ImportError:
        print("pykeepass is not installed", file=sys.stderr)
        sys.exit(1)

    password = None if args.no_password else input("Enter password to unlock database: ")

    try:
        kp = PyKeePass(args.database, password=password, keyfile=args.key_file)
    except CredentialsError:
        print("Error: invalid credentials for KeePass database", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    # Support group/title path (e.g. "Group/Entry")
    parts = args.entry.rsplit("/", 1)
    if len(parts) == 2:
        entry = kp.find_entries(title=parts[1], group=kp.find_groups(name=parts[0], first=True), first=True)
    else:
        entry = kp.find_entries(title=args.entry, first=True)

    if entry is None:
        print(f"Error: entry '{args.entry}' not found in database", file=sys.stderr)
        sys.exit(1)

    attr = args.attributes
    if attr == "Password":
        value = entry.password
    elif attr == "UserName":
        value = entry.username
    elif attr == "URL":
        value = entry.url
    elif attr == "Notes":
        value = entry.notes
    elif attr == "Title":
        value = entry.title
    else:
        value = entry.custom_properties.get(attr)

    if value is None:
        print(f"Error: attribute '{attr}' not found on entry '{args.entry}'", file=sys.stderr)
        sys.exit(1)

    print(value)


def lookup_secret_service(entry_label):
    try:
        import secretstorage
    except ImportError:
        print("secretstorage is not installed", file=sys.stderr)
        sys.exit(1)

    try:
        connection = secretstorage.dbus_init()
    except Exception as e:
        print(f"Error: could not connect to D-Bus: {e}", file=sys.stderr)
        print("Ensure the host D-Bus session socket is mounted into the container.", file=sys.stderr)
        print("See KEEPASSXC-CLI.md for setup instructions.", file=sys.stderr)
        sys.exit(1)

    try:
        collection = secretstorage.get_default_collection(connection)
        if collection.is_locked():
            print("Error: the default secret service collection is locked", file=sys.stderr)
            sys.exit(1)

        # Search by label first, then fall back to any attribute match
        items = list(collection.search_items({"label": entry_label}))
        if not items:
            # Broader search — some Secret Service providers index differently
            items = [i for i in collection.get_all_items() if i.get_label() == entry_label]

        if not items:
            print(f"Error: no secret service item found with label '{entry_label}'", file=sys.stderr)
            sys.exit(1)

        print(items[0].get_secret().decode())
    except Exception as e:
        print(f"Error: secret service lookup failed: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command")                           # 'show'
    parser.add_argument("--show-protected", action="store_true")
    parser.add_argument("--attributes", "-a", default="Password")
    parser.add_argument("--no-password", action="store_true")
    parser.add_argument("--key-file", "-k", default=None)
    parser.add_argument("--secret-service", action="store_true")
    parser.add_argument("--yubikey", default=None)           # unsupported, accepted silently
    parser.add_argument("database", nargs="?", default=None) # not used for secret-service
    parser.add_argument("entry")
    args = parser.parse_args()

    if args.command != "show":
        print(f"Unsupported command: {args.command}", file=sys.stderr)
        sys.exit(1)

    if args.secret_service:
        lookup_secret_service(args.entry)
    else:
        if not args.database:
            print("Error: database path required for file-based lookup", file=sys.stderr)
            sys.exit(1)
        lookup_file(args)


if __name__ == "__main__":
    main()
SHIM

chmod +x /usr/local/bin/keepassxc-cli
echo "[init-keepassxc-cli] Done. keepassxc-cli shim is ready."
