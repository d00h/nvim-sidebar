import sys
from argparse import ArgumentParser
from argparse import Namespace as ArgumentNamespace
from os import getenv, path
from pprint import pprint

import requests


class GrafanaClient:

    """
        https://grafana.com/docs/grafana/latest/http_api/data_source/
    """

    def __init__(self, url, apikey):
        if not url:
            raise ValueError('no URL')
        self.url = url
        if not apikey:
            raise ValueError('no APIKEY')
        self.apikey = apikey

    def request_get(self, uri):
        url = path.join(self.url, uri)

        resp = requests.get(url, headers={
            'Authorization': f'Bearer {self.apikey}'
        })

        if not resp.ok:
            resp.raise_for_status()
        return resp

    def request_post(self, uri, json):
        url = path.join(self.url, uri)

        resp = requests.get(url, headers={
            'Authorization': f'Bearer {self.apikey}'
        })

        if not resp.ok:
            resp.raise_for_status()
        return resp

    def health(self):
        resp = self.request_get('api/health')
        return resp.json()

    def find_datasources(self):
        resp = self.request_get('api/datasources')
        return resp.json()

    def query(self, query):
        """
            https://grafana.com/docs/grafana/latest/http_api/data_source/#query-a-data-source-by-id
        """
        resp = self.request_post(
            'api/tsdb/query',
            json={
                "from": "1420066800000",
                "to": "1575845999999",
                "queries": [
                    {
                      "refId": "A",
                      "datasourceId": 1,
                      "intervalMs": 86400000,
                      "maxDataPoints": 1092,
                      "rawSql": query,
                      "format": "table"
                    }
                ]
            })
        return resp.json()


def create_parser() -> ArgumentParser:
    parser = ArgumentParser()
    parser.add_argument('--url', default=getenv('GRAFANA_URL'))
    parser.add_argument('--apikey', default=getenv('GRAFANA_APIKEY'))

    subparsers = parser.add_subparsers()

    find_datasources_parser = subparsers.add_parser('find-datasources')
    find_datasources_parser.set_defaults(command=command_find_projects)

    query_parser = subparsers.add_parser('query')
    query_parser.set_defaults(command=command_query)

    health_parser = subparsers.add_parser('health')
    health_parser.set_defaults(command=command_health)

    return parser

# eyJrIjoiQUkzeVFUR0ZqZjdYZG0wSDlTc1ZJdWFKS0lUbmNWYmsiLCJuIjoiZDAwaDIiLCJpZCI6MX0=


def command_health(grafana: GrafanaClient, args: ArgumentNamespace):
    health = grafana.health()
    pprint(health)


def command_find_projects(grafana: GrafanaClient, args: ArgumentNamespace):
    print('# Datasources\n')
    datasources = grafana.find_datasources()
    pprint(datasources)


def command_query(grafana: GrafanaClient, args: ArgumentNamespace):
    print('# Datasources\n')
    result = grafana.query("SELECT 1 as valueOne, 2 as valueTwo")
    pprint(result)
    # projects.sort()
    # for project in projects:
    #     print(project)


def main():
    parser = create_parser()
    if len(sys.argv) == 1:
        parser.print_help()
        return
    args = parser.parse_args()

    try:
        grafana = GrafanaClient(url=args.url, apikey=args.apikey)
        args.command(grafana, args)
    except BaseException as ex:
        print('error:', ex)


if __name__ == '__main__':
    main()
