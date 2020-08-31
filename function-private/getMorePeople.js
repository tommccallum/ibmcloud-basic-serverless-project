//------------------------------------------------------------------------------
// Copyright IBM Corp. 2018
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

var Cloudant = require('@cloudant/cloudant');

function main(params) {

    return new Promise(function (resolve, reject) {
        try {
            let cloudant = new Cloudant({
                account: params.config.cloudant_username,
                plugins: {
                    iamauth: {
                        iamApiKey: params.config.cloudant_key
                    }
                }
            });
            let db = cloudant.db.use('serverlessweb');

            db.find({ selector: { firstname: 'Catherine' } }, function (err, result) {
                if (err) {
                    reject({ error: err })
                }
                if (result.docs.length > 0) {
                    resolve(result.docs[0]);
                }
                else {
                    resolve({ fromCloudant: 'nothing found' });
                }
            });
        }
        catch (error) {
            reject({ error: error })
        }
    })
}