from cloudant.client import Cloudant
from cloudant.error import CloudantException
from cloudant.result import Result, ResultByKey
import sys
import os

# bring in these from the environment
account_name = os.environ.get("IBM_CLOUDANT_USERNAME")
api_key = os.environ.get("IBM_CLOUDANT_API_KEY")
db_name = sys.argv[1]
if db_name is None or len(db_name) == 0:
    raise ValueError("db_name is empty")
client = Cloudant.iam(account_name, api_key, connect=True)
client.connect()

db = client.create_database(db_name) #, partitioned=True)
if not db.exists():
    print("Database {} was not created as expected.".format(db_name))
    sys.exit(1)

print("Database {} was successfully created\n".format(db_name))
sys.exit(0)

