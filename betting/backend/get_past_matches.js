const sdk = require('api')('@developers-pandascore/v2#apvn9q1ml4sw7gei');
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

sdk.auth(process.env.APIKEY);

sdk['get_matches_past']({
    'filter[finished]': 'true',
    'filter[not_started]': 'false',
    sort: '',
    page: '1',
    per_page: '1'
})
    .then(res => console.log(res))
    .catch(err => console.error(err));