const sdk = require('api')('@developers-pandascore/v2#e90xv1xl4sw7ghr');
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

sdk.auth(process.env.APIKEY);

sdk['get_csgo_matches_running']({ sort: 'begin_at', page: '1', per_page: '1' })
    .then(res => console.log(res))
    .catch(err => console.error(err));