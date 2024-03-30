#!/usr/bin/env python3
import mailbox
import click
import os

@click.command()
@click.option('-m', '--mbox',    help='Input mailbox or maildir to read.', type=click.Path(exists=True, file_okay=True, dir_okay=True, readable=True), default='-')
@click.option('-o', '--output',  help='Output list (default: stdout)', type=click.File('w'), default='-')
@click.option('-x', '--exclude', help='Exclude email addresses matching given regex.')
@click.option('-t', '--to',      help='Use to:-header', is_flag=True)
@click.option('-f', '--frm',     help='Use from:-header', is_flag=True)
@click.option('-c', '--cc',      help='Use cc:-header', is_flag=True)
@click.option('-b', '--bcc',     help='Use bcc:-header', is_flag=True)
@click.option('-v', '--verbose', help="Be verbose.", count=True)
def mailbox_extract(mbox, output, exclude, to, frm, cc, bcc, verbose):
    """Extract eMail addresses from mailbox/maildir."""
    if os.path.isdir(mbox):
        mb = mailbox.Maildir(mbox)
    else:
        mb = mailbox.mbox(mbox)

    def add(emails):
        if emails and isinstance(emails, str):
            output.write("\n".join(emails.split(",")) + "\n")

    for i, msg in enumerate(mb):
        if verbose:
            print(f"{msg['from']} => {msg['to']},{msg['cc']}: {msg['subject']}")
        if to:
            add(msg['to'])
        if frm:
            add(msg['from'])
        if cc:
            add(msg['cc'])
        if bcc:
            add(msg['bcc'])


if __name__ == '__main__':
    mailbox_extract(auto_envvar_prefix='MAILBOX_EXTRACT')
