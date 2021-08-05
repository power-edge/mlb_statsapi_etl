"""Console script for mlb_statsapi."""
import argparse
import json
import os.path
import sys

from mlb_statsapi.model import StatsAPI

class Arguments:

    @staticmethod
    def date(add_argument: callable, required: bool = False):
        from mlb_statsapi.utils import get_current_mlb_date
        add_argument(
            '--date',
            type=str,
            required=required,
            default=str(get_current_mlb_date())
        )

    @staticmethod
    def gamePk(add_argument: callable, required: bool = True):
        add_argument(
            '--gamePk',
            type=int,
            required=required
        )

    @staticmethod
    def startTime(add_argument: callable, required: bool = True):
        add_argument(
            '--startTime',
            type=str,
            required=required
        )

    @staticmethod
    def sportId(add_argument: callable, required: bool = False):
        add_argument(
            '--sportId',
            type=int,
            required=required,
            default=1
        )


def add_subparsers(parser):
    subparsers = parser.add_subparsers(help='application to run', dest='app', required=True)
    app_parsers = {}
    for app in Apps:  # skip api_docs
        name = app.__name__
        app_parsers[name] = subparsers.add_parser(name)

        # app_parsers[name].add_argument(
        #     '-m',
        #     '--methods',
        #     nargs='+',
        #     default=[*api.methods.keys()],
        #     help='StatsAPI Model method filter. default is all.'
        # )

    Arguments.date(app_parsers['Schedule'].add_argument, True)
    Arguments.sportId(app_parsers['Schedule'].add_argument)

    Arguments.date(app_parsers['Game'].add_argument, True)
    Arguments.gamePk(app_parsers['Game'].add_argument)
    Arguments.startTime(app_parsers['Game'].add_argument)
    Arguments.sportId(app_parsers['Game'].add_argument)

    return subparsers


def parse_args():
    """Console script for mlb_statsapi."""
    parser = argparse.ArgumentParser()
    parser.add_argument('--indent', default=2, required=False, type=int)

    subparsers = add_subparsers(parser)

    return parser.parse_args()


def Game(args: argparse.Namespace):
    from mlb_statsapi import apps
    return apps.Game.run(
        date=args.date,
        gamePk=args.gamePk,
        startTime=args.startTime,
        sportId=args.sportId
    )


def Schedule(args: argparse.Namespace):
    from mlb_statsapi import apps
    return apps.Schedule.run(
        sportId=args.sportId,
        date=args.date
    )


Apps = [
    Game,
    Schedule
]


def main():
    args = parse_args()
    # print("args: %s" % args)
    print(json.dumps({
        'Game': Game,
        'Schedule': Schedule
    }[args.app](args), indent=args.indent))


if __name__ == "__main__":
    sys.exit(main())
