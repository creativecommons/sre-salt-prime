#!{{ DIR_ENV }}/bin/python
from flup.server.fcgi import WSGIServer
from paste.deploy import loadapp
from paste.exceptions.errormiddleware import ErrorMiddleware

CCENGINE_CONFIG_PATH = '{{ DIR_ENV }}/config.ini'


def launch_ccengine_fcgi():
    ccengine_wsgi_app = loadapp('config:{}'.format(CCENGINE_CONFIG_PATH))
    WSGIServer(ccengine_wsgi_app).run()


if __name__ == '__main__':
    launch_ccengine_fcgi()
