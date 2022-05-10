import sys
from argparse import ArgumentParser
from argparse import Namespace as ArgumentNamespace
from os import getenv, path
from pprint import pprint

import requests


class JiraClient:

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
        """ https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-projects/ """
        resp = self.request('rest/api/latest/project')
        for item in resp.json():
            key = item.get('key')
            name = item.get('name')
            yield f'{key}: {name}'

    def find_issues(self, jql):
        """ https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-get """
        resp = self.request(f'rest/api/latest/search?jql={jql}')

        issues = resp.json().get('issues')

        for issue in issues:
            fields = issue.get('fields', {})
            key = issue.get('key')
            summary = fields.get('summary')
            status = fields.get('status', {}).get('name')
            yield f'{key}: {summary}({status})'

    def get_issue(self, issue):
        """ https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-get """
        resp = self.request(f'rest/api/latest/issue/{issue}/')

        data = resp.json()

        fields = data.get('fields', {})
        key = data.get('key') or ''
        summary = fields.get('summary') or ''

        created = fields.get('created') or ''
        status = fields.get('status', {}).get('name') or ''
        description = fields.get('description') or ''
        assignee = fields.get('displayName') or ''
        url = path.join(self.url, 'browse', issue)

        return '\n'.join([
            f'# {key} {summary} ({status}) {assignee}',
            '',
            f'Создано: {created}',
            '',
            url,
            '',
            description,
        ])


def create_parser() -> ArgumentParser:
    parser = ArgumentParser()
    parser.add_argument('--url', default=getenv('JIRA_URL'))
    parser.add_argument('--apikey', default=getenv('JIRA_APIKEY'))

    subparsers = parser.add_subparsers()

    find_projects_parser = subparsers.add_parser('find-projects')
    find_projects_parser.set_defaults(command=command_find_projects)

    find_issues_parser = subparsers.add_parser('find-issues')
    find_issues_parser.add_argument('jql', nargs='+')
    find_issues_parser.set_defaults(command=command_find_issues)

    get_issue_parser = subparsers.add_parser('get-issue')
    get_issue_parser.add_argument('issue')
    get_issue_parser.set_defaults(command=command_get_issue)

    return parser


def command_find_projects(jira: JiraClient, args: ArgumentNamespace):
    for project in jira.find_projects():
        print(project)


def command_find_issues(jira: JiraClient, args: ArgumentNamespace):
    for issues in jira.find_issues(' '.join(args.jql)):
        print(issues)


def command_get_issue(jira: JiraClient, args: ArgumentNamespace):
    issue = jira.get_issue(args.issue)
    print(issue)


def main():
    parser = create_parser()
    if len(sys.argv) == 1:
        parser.print_help()
        return

    args = parser.parse_args()
    try:
        jira = JiraClient(url=args.url, apikey=args.apikey)
        args.command(jira, args)
    except BaseException as ex:
        print('error:', ex)


if __name__ == '__main__':
    main()
