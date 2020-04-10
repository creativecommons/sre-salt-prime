#!{{ DIR_ENV }}/bin/python
# vim: set fileencoding=utf-8:
# Managed by SaltStack: {{ SLS }}
from flup.server.fcgi import WSGIServer
from paste.deploy import loadapp
from paste.exceptions.errormiddleware import ErrorMiddleware


def launch_ccengine_fcgi():
    ccengine_wsgi_app = loadapp('config:config.ini', relative_to='..')
    WSGIServer(ccengine_wsgi_app).run()


if __name__ == '__main__':
    launch_ccengine_fcgi()
