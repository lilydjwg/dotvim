import collections
import re

from deoplete.source.base import Base

try:
    from beancount.loader import load_file
    from beancount.core import data
    HAS_BEANCOUNT = True
except ImportError:
    HAS_BEANCOUNT = False

DIRECTIVES = [
    'open', 'close', 'commodity', 'txn', 'balance', 'pad', 'note', 'document',
    'price', 'event', 'query', 'custom'
]


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.vim = vim

        self.name = 'beancount'
        self.mark = '[bc]'
        self.filetypes = ['beancount']
        self.rank = 500
        self.min_pattern_length = 0
        self.attributes = collections.defaultdict(list)

    def on_init(self, context):
        if not HAS_BEANCOUNT:
            self.error('Importing beancount failed.')

    def on_event(self, context):
        if context['event'] in ('Init', 'BufWritePost'):
            # Make cache on BufNewFile, BufRead, and BufWritePost
            self.__make_cache(context)

    def get_complete_position(self, context):
        m = re.search(r'\S*$', context['input'])
        return m.start() if m else -1

    def gather_candidates(self, context):
        attrs = self.attributes
        if re.match(r'^\d{4}[/-]\d\d[/-]\d\d \w*$', context['input']):
            return [{'word': x, 'kind': 'directive'} for x in DIRECTIVES]
        # line that starts with whitespace (-> accounts)
        if re.match(r'^(\s)+[\w:]+$', context['input']):
            return [{'word': x, 'kind': 'account'} for x in attrs['accounts']]
        # directive followed by account
        if re.search(
                r'(balance|document|note|open|close|pad(\s[\w:]+)?)'
                r'\s[\w:]+$',
                context['input']):
            return [{'word': x, 'kind': 'account'} for x in attrs['accounts']]
        # events
        if re.search(r'event "[^"]*$', context['input']):
            return [{
                'word': '"{}"'.format(x),
                'kind': 'event'
            } for x in attrs['events']]
        # commodity after number
        if re.search(r'\s([0-9]+|[0-9][0-9,]+[0-9])(\.[0-9]*)?\s\w+$',
                     context['input']):
            return [{
                'word': x,
                'kind': 'commodity'
            } for x in attrs['commodities']]
        if not context['complete_str']:
            return []
        first = context['complete_str'][0]
        if first == '#':
            return [{'word': '#' + w, 'kind': 'tag'} for w in attrs['tags']]
        elif first == '^':
            return [{'word': '^' + w, 'kind': 'link'} for w in attrs['links']]
        elif first == '"':
            return [{
                'word': '"{}"'.format(w),
                'kind': 'payee'
            } for w in attrs['payees']]
        return []

    def __make_cache(self, context):
        if not HAS_BEANCOUNT:
            return

        entries, _, options = load_file(self.vim.eval("beancount#get_root()"))

        accounts = set()
        events = set()
        links = set()
        payees = set()
        tags = set()

        for entry in entries:
            if isinstance(entry, data.Open):
                accounts.add(entry.account)
            elif isinstance(entry, data.Transaction):
                if entry.payee:
                    payees.add(entry.payee)
            if hasattr(entry, 'links') and entry.links:
                links.update(entry.links)
            if hasattr(entry, 'tags') and entry.tags:
                tags.update(entry.tags)
            if isinstance(entry, data.Event):
                events.add(entry.type)

        self.attributes = {
            'accounts': sorted(accounts),
            'events': sorted(events),
            'commodities': options['commodities'],
            'links': sorted(links),
            'payees': sorted(payees),
            'tags': sorted(tags),
        }
