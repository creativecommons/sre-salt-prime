# vim: set fileencoding=utf-8:

# Standard library
from random import choice
import os.path

# Third-party
from locust import TaskSet, between, task
from locust.contrib.fasthttp import FastHttpLocust


HOST_STAGE = "https://stage.creativecommons.org"
PATH_BY = "/licenses/by"
PATH_ZERO = "/publicdomain/zero"
CODE_BY_FOUR = [
    "ar",
    "cs",
    "de",
    "el",
    "en",
    "es",
    "eu",
    "fi",
    "fr",
    "hr",
    "id",
    "it",
    "ja",
    "ko",
    "lt",
    "lv",
    "mi",
    "nl",
    "no",
    "pl",
    "pt",
    "ru",
    "sv",
    "tr",
    "uk",
    "zh-Hans",
    "zh-Hant",
]
CODE_BY_THREE = [
    "am",
    "at",
    "au",
    "az",
    "br",
    "ca_en",
    "ca_fr",
    "ch_de",
    "ch_fr",
    "cl",
    "cn",
    "cr",
    "cz",
    "de",
    "ec",
    "ee",
    "eg",
    "es_ast",
    "es_ca",
    "es_es",
    "es_eu",
    "es_gl",
    "es_oci",
    "fr",
    "ge",
    "gr",
    "gt",
    "hk",
    "hr",
    "ie",
    "igo",
    "igo_ar",
    "igo_fr",
    "it",
    "lu",
    "nl",
    "no",
    "nz",
    "ph",
    "pl",
    "pr",
    "pt",
    "ro",
    "rs_sr-Cyrl",
    "rs_sr-Latn",
    "sg",
    "th",
    "tw",
    "ug",
    "us",
    "ve",
    "vn",
    "za",
]
CODE_ZERO_ONE = [
    "el",
    "en",
    "es",
    "eu",
    "fi",
    "fr",
    "it",
    "ja",
    "ko",
    "lt",
    "lv",
    "nl",
    "pl",
    "sv",
    "zh-Hans",
    "zh-Hant",
]


def client_get(browselegaltools, *argv):
    """
    GET deed/legalcode/rdf URI (after combining the provided URI components)
    """
    uri = os.path.join(*argv)
    if "BUSTCACHE" in os.environ and os.environ["BUSTCACHE"]:
        uri = f"{uri}?{os.environ['BUSTCACHE']}"
    browselegaltools.client.get(uri)


class BrowseLegalTools(TaskSet):
    @task(2)
    def deed_by_four(self):
        """
        Task: get CC BY 4.0 deed
        """
        client_get(self, PATH_BY, "4.0", f"deed.{choice(CODE_BY_FOUR)}")

    @task(1)
    def legalcode_by_four(self):
        """
        Task: get CC BY 4.0 legalcode
        """
        client_get(self, PATH_BY, "4.0", f"legalcode.{choice(CODE_BY_FOUR)}")

    @task(2)
    def deed_by_three(self):
        """
        Task: get CC BY 3.0 deed
        """
        code = choice(CODE_BY_THREE)
        if code in ("ca_en", "ca_fr"):
            return
        elif "_" in code:
            jurisdiction, language = code.split("_")
            page = f"deed.{language}"
            client_get(self, PATH_BY, "3.0", jurisdiction, page)
        else:
            page = f"deed.{code}"
            client_get(self, PATH_BY, "3.0", page)

    @task(1)
    def legalcode_by_three(self):
        """
        Task: get CC BY 3.0 legalcode
        """
        base = PATH_BY
        version = "3.0"
        code = choice(CODE_BY_THREE)
        if "_" in code:
            jurisdiction, language = code.split("_")
            page = f"legalcode.{language}"
            client_get(self, base, version, jurisdiction, page)
        else:
            page = f"legalcode.{code}"
            client_get(self, base, version, page)

    @task(2)
    def deed_zero_one(self):
        """
        Task: get CC ZERO 1.0 deed
        """
        client_get(self, PATH_ZERO, "1.0", f"deed.{choice(CODE_ZERO_ONE)}")

    @task(1)
    def legalcode_zero_one(self):
        """
        Task: get CC ZERO 1.0 legalcode
        """
        client_get(
            self, PATH_ZERO, "1.0", f"legalcode.{choice(CODE_ZERO_ONE)}"
        )

    @task(1)
    def rdf(self):
        """
        Task: get CC RDF
        """
        client_get(
            self,
            PATH_BY.rstrip("/by"),
            choice(("by-nc-nd", "by-nc-sa", "by-nc", "by-nd", "by-sa", "by")),
            choice(("4.0", "3.0", "2.0", "1.0")),
            "rdf",
        )

    @task(3)
    def deed_wrong_index(self):
        """
        Task: get CC RDF
        """
        client_get(
            self,
            PATH_BY.rstrip("/by"),
            choice(("by-nc-nd", "by-nc-sa", "by-nc", "by-nd", "by-sa", "by")),
            choice(("4.0", "3.0", "2.0", "1.0")),
            "index.php",
        )


class LegalToolsUser(FastHttpLocust):
    host = HOST_STAGE
    task_set = BrowseLegalTools
    wait_time = between(2, 16)
