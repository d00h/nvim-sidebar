import sys
from argparse import ArgumentParser
from argparse import Namespace as ArgumentNamespace
from os import path, getenv
from pprint import pprint

import requests


class SentryClient:

    def __init__(self, url, apikey):
        if not url:
            raise ValueError('no URL')
        self.url = url
        if not apikey:
            raise ValueError('no APIKEY')
        self.apikey = apikey

    def request(self, uri):
        url = path.join(self.url, uri)

        resp = requests.get(url, headers={
            'Authorization': f'Bearer {self.apikey}'
        })

        if not resp.ok:
            resp.raise_for_status()
        return resp

    def find_projects(self):
        resp = self.request('api/0/projects/')
        for item in resp.json():
            project_name = item.get('name')
            project_status = item.get('status')
            if project_name and project_status == 'active':
                yield project_name

    def find_issues(self, organization, project):
        resp = self.request(f'api/0/projects/{organization}/{project}/issues/')
        for item in resp.json():
            id = item.get('id')
            title = item.get('title')
            yield f'{id}: {title}'

    def get_issue(self, issue):
        resp = self.request(f'api/0/issues/{issue}/')
        return resp.json()

    def find_events(self, issue):
        resp = self.request(f'api/0/issues/{issue}/events/')
        for item in resp.json():
            id = item.get('id')
            if id:
                yield id

    def get_event(self, organization, project, event):
        resp = self.request(f'api/0/projects/{organization}/{project}/events/{event}/')
        return resp.json()



def create_parser() -> ArgumentParser:
    parser = ArgumentParser()
    parser.add_argument('--url', default=getenv('SENTRY_URL'))
    parser.add_argument('--apikey', default=getenv('SENTRY_APIKEY'))
    parser.add_argument('--organization', default=getenv('SENTRY_ORGANIZATION'))
    parser.add_argument('--project', default=getenv('SENTRY_PROJECT'))

    subparsers = parser.add_subparsers()

    find_projects_parser = subparsers.add_parser('find-projects')
    find_projects_parser.set_defaults(command=command_find_projects)

    find_issues_parser = subparsers.add_parser('find-issues')
    find_issues_parser.add_argument('project')
    find_issues_parser.set_defaults(command=command_find_issues)

    cat_issue_parser = subparsers.add_parser('cat-issue')
    cat_issue_parser.add_argument('issue')
    cat_issue_parser.set_defaults(command=command_cat_issue)

    find_events_parser = subparsers.add_parser('find-events')
    find_events_parser.add_argument('issue')
    find_events_parser.set_defaults(command=command_find_events)

    cat_event_parser = subparsers.add_parser('cat-event')
    cat_event_parser.add_argument('event')
    cat_event_parser.set_defaults(command=command_cat_event)

    return parser


def command_find_projects(sentry: SentryClient, args: ArgumentNamespace):
    print('# Projects\n')
    projects = list(sentry.find_projects())
    projects.sort()
    for project in projects:
        print(project)


def command_find_issues(sentry: SentryClient, args: ArgumentNamespace):
    print(f'# Issues({args.project})\n')
    issues = list(sentry.find_issues(args.organization, args.project))
    for issue in issues:
        print(issue)


def command_cat_issue(sentry: SentryClient, args: ArgumentNamespace):
    print(f'# Issue({args.issue})\n')
    issue = sentry.get_issue(args.issue)
    pprint(issue)


def command_find_events(sentry: SentryClient, args: ArgumentNamespace):
    print(f'# Events({args.issue})\n')
    events = list(sentry.find_events(args.issue))
    for event in events:
        print(event)


def command_cat_event(sentry: SentryClient, args: ArgumentNamespace):
    print(f'# Events({args.event})\n')
    event = sentry.get_event(args.organization, args.project, args.event)
    pprint(event)


def main():
    parser = create_parser()
    if len(sys.argv) == 1:
        parser.print_help()
        return
    args = parser.parse_args()

    try:
        sentry = SentryClient(url=args.url, apikey=args.apikey)
        args.command(sentry, args)
    except BaseException as ex:
        print('error:', ex)


if __name__ == '__main__':
    main()
