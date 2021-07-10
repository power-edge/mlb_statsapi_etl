"""Console script for mlb_statsapi."""
import argparse
import os.path
import sys
path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
sys.path.append(path)

from mlb_statsapi.model import StatsAPI


def app_subparsers(parser):
    subparsers = parser.add_subparsers(help='application to run', dest='app')
    app_parsers = {}
    for api in StatsAPI.ALL[1:]:  # skip api_docs
        name = api.get_name()
        app_parsers[name] = subparsers.add_parser(name)

        app_parsers[name].add_argument(
            '-m',
            '--methods',
            nargs='+',
            default=[*api.methods.keys()],
            help='StatsAPI Model method filter. default is all.'
        )

    app_parsers['game'].add_argument(
        '-pk',
        '--game_pk',
        type=int,
        required=True
    )

    return subparsers


def parse_args():
    """Console script for mlb_statsapi."""
    parser = argparse.ArgumentParser()

    subparsers = app_subparsers(parser)

    return parser.parse_args()


def main():
    from mlb_statsapi.apps import Apps
    args = parse_args()
    print("args: %s" % args)
    return {
        'config': Apps.Config,
    }[args.app]().main(args)


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover


# boxscore,colorFeed,colorTimestamps,content,currentGameStats,getGameContextMetrics,getWinProbability,linescore,liveGameDiffPatchV1,liveGameV1,liveTimestampv11,playByPlay