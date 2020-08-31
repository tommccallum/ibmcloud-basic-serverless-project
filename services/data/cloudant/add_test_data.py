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
for a in client.all_dbs():
    print(a)

db = client.get(db_name, None, True)
if db is None:
    print("Failed to find database: {}".format(db_name))
    sys.exit(1)

people = [
    {"firstname": "Catherine", "lastname": "May"},
    {"firstname": "Arthur", "lastname": "Mann"}
]


# Create documents using the sample data.
# Go through each row in the array
for jsonDocument in people:
    # Create a document using the Database API.
    newDocument = db.create_document(jsonDocument)

    # Check that the document exists in the database.
    if newDocument.exists():
        print("Document '{} {}' successfully created.".format(jsonDocument["firstname"], jsonDocument["lastname"]))

index = db.create_query_index( design_document_id='query', index_name='firstname-index', fields=["firstname"], partitioned=False)
index.create()

