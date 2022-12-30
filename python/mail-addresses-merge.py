#!/usr/bin/env python3
import mailbox
import click
import sys
import re

@click.command()
@click.option('-f', '--file',    help='File with eMail addresses to read and write back.', type=click.File('r+'))
@click.option('-a', '--add',     help='File with addresses to add (default: stdin)', type=click.File('r'), default='-')
@click.option('-x', '--exclude', help='Exclude email addresses matching given regex.')
@click.option('-v', '--verbose', help="Be verbose.", count=True)
def mail_addresses_merge(file, add, exclude, verbose):
    """Merge and normalize list with eMail addresses."""
    emails = EmailCollection(file.readlines(), exclude, verbose)
    for line in add.readlines():
        if verbose:
            print(f"{line}")
        emails.add(line)
    file.seek(0)
    file.truncate()
    for i in emails.get():
        file.write(f"{i}\n")


class EmailCollection():
    def __init__(self, emails=[], exclude=None, verbose=False):
        self.emails = [ email.strip().lower() for email in emails ]
        self.exclude = None
        if exclude:
            self.exclude = re.compile(exclude)
        self.verbose = verbose
        self.regex = re.compile(r'([-._A-Za-z0-9]+@[-.A-Za-z0-9]+)')
    def add(self, emails):
    	if not emails:
            return
    	for email in emails.split(','):
            self.add_one(email)
    def add_one(self, email):
        if not email:
            return
        match = self.regex.search(email)
        if match:
            addr = match.group(1)
            if addr:
                addr = addr.lower()
                if self.exclude and self.exclude.match(addr):
                    return
                self.emails.append(addr)
                if self.verbose:
                    print(f"+ {addr}")
    def get(self):
        self.emails = [ email.strip().lower() for email in self.emails if email != "" and "@" in email ]
        lst = list(set(self.emails))
        #lst.sort()
        lst = sorted(lst, key=lambda x: x.split('@')[1])
        return lst


if __name__ == '__main__':
    mail_addresses_merge(auto_envvar_prefix='MAIL_ADDRESSES_MERGE')
