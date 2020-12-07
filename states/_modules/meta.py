# NOTE: To enable this custom execution module on the salt-master (ex. for use
#       in pillars), you must first run:
#
#           sudo salt-run saltutil.sync_modules
#
#       Only a single location/environment is supported. During development,
#       you may wish to run:
#
#           sudo salt-run saltutil.sync_modules saltenv=${USER}


def classify(minion_id=None):
    if not minion_id:
        minion_id = __grains__["id"]
    # minion classification schema v1: hostrole__podgroup__location
    hostrole, podgroup, location = minion_id.split("__")
    location = location.replace("_master", "")
    podgroup__location = "{}__{}".format(podgroup, location)
    hostrole__podgroup = "{}__{}".format(hostrole, podgroup)
    return [
        minion_id,
        hostrole,
        podgroup,
        location,
        podgroup__location,
        hostrole__podgroup,
    ]


def rds_endpoint(minion_id=None):
    _, hostrole, podgroup, location, _, _ = classify(minion_id)
    kwargs = {
        "name": "-".join([hostrole, podgroup, "rdsdb"]),
        "region": location,
        "jmespath": "DBInstances[0].Endpoint.Address"
    }
    endpoint = __salt__["boto_rds.describe_db_instances"](**kwargs)[0]
    return endpoint
