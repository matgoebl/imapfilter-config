#!/usr/bin/env python3
import click
import vobject
import sys

@click.command()
@click.option('-f', '--vcf',        help='VCards file to read.', type=click.File('r'), required=True)
@click.option('-x', '--extract',    help='Field to extract.')
@click.option('-c', '--categories', help='Select given categories, comma separated')
@click.option('-v', '--verbose',    help="Be verbose.", count=True)
def vcard_extract(vcf, categories, extract, verbose):
    """Extract field from vcards."""

    for vcard in vobject.readComponents(vcf):
        for attr in vcard.getChildren():
            if attr.name in ('CATEGORIES'):
                categories_vcard = attr.valueRepr()
                if not categories or set(categories.split(',')).intersection(set(categories_vcard)):
                    if verbose:
                        print(f"=====  {vcard.contents['fn'][0].valueRepr()}  =====\n{vcard}\n===")  #, file=sys.stderr)

                    if extract and extract in vcard.contents:
                        for field in vcard.contents[extract]:
                            val = field.valueRepr()
                            if isinstance(val, list):
                                val = ",".join(val)
                            print(val)


if __name__ == '__main__':
    vcard_extract(auto_envvar_prefix='VCARD_EXTRACT')
