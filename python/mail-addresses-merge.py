#!/usr/bin/env python3
import mailbox
import click
import sys
import re
import glob

@click.command()
@click.option('-f', '--file',    help='File with eMail addresses to read and write back.', type=click.File('r+'), required=True)
@click.option('-a', '--add',     help='File with addresses to add (default: stdin)', type=click.File('r'), default='-')
@click.option('-x', '--exclude', help='Exclude email addresses matching given regex.')
@click.option('-e', '--existing',help='Exclude existing email addresses found in files matching the given file glob (e.g. lists/*.senders).')
@click.option('-v', '--verbose', help="Be verbose.", count=True)
def mail_addresses_merge(file, add, exclude, existing, verbose):
    """Merge and normalize list with eMail addresses."""
    emails = EmailCollection(file.readlines(), exclude, existing, verbose)
    if verbose:
        print(f"* merging to {file.name}:")
    for line in add.readlines():
        if verbose:
            print(f"{line}")
        emails.add(line)
    file.seek(0)
    file.truncate()
    for i in emails.get():
        file.write(f"{i}\n")


class EmailCollection():
    def __init__(self, emails=[], exclude=None, existing=None, verbose=False):
        self.emails = [ email.strip().lower() for email in emails ]
        self.exclude = None
        if exclude:
            self.exclude = re.compile(exclude)
        self.verbose = verbose
        self.validemail = re.compile(r'([-._A-Za-z0-9]+@[-.A-Za-z0-9]+)')
        self.existing = []
        if existing:
            for filename in sorted(glob.glob(existing)):
                if self.verbose:
                    print(f"* reading existing {filename}...")
                with open(filename) as f:
                    self.existing += [ email.strip().lower() for email in f.readlines() ]
        if self.verbose:
            print(f"* list of existing addresses:\n{self.existing}")

    def add(self, emails):
    	if not emails:
            return
    	for email in emails.split(','):
            self.add_one(email)
    def add_one(self, email):
        if not email:
            return
        match = self.validemail.search(email)
        if match:
            addr = match.group(1)
            if addr:
                addr = addr.lower()
                if self.exclude and self.exclude.match(addr):
                    return
                if addr in self.existing:
                    return
                self.emails.append(addr)
                if self.verbose:
                    print(f"+ {addr}")
    def get(self):
        self.emails = [ email.strip().lower() for email in self.emails if email != "" and "@" in email ]
        lst = list(set(self.emails))
        lst = sorted(lst, key=lambda x: x.split('@')[1] + "@" + x.split('@')[0])
        return lst


if __name__ == '__main__':
    mail_addresses_merge(auto_envvar_prefix='MAIL_ADDRESSES_MERGE')
