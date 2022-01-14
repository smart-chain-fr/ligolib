"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.smartContractAbstractionSemantic = void 0;
var michelson_encoder_1 = require("@taquito/michelson-encoder");
var big_map_1 = require("./big-map");
var bignumber_js_1 = require("bignumber.js");
var sapling_state_abstraction_1 = require("./sapling-state-abstraction");
// Override the default michelson encoder semantic to provide richer abstraction over storage properties
var smartContractAbstractionSemantic = function (provider) { return ({
    // Provide a specific abstraction for BigMaps
    big_map: function (val, code) {
        if (!val || !('int' in val) || val.int === undefined) {
            // Return an empty object in case of missing big map ID
            return {};
        }
        else {
            var schema = new michelson_encoder_1.Schema(code);
            return new big_map_1.BigMapAbstraction(new bignumber_js_1.default(val.int), schema, provider);
        }
    },
    sapling_state: function (val) {
        if (!val || !('int' in val) || val.int === undefined) {
            // Return an empty object in case of missing sapling state ID
            return {};
        }
        else {
            return new sapling_state_abstraction_1.SaplingStateAbstraction(new bignumber_js_1.default(val.int), provider);
        }
    }
    /*
    // TODO: embed useful other abstractions
    'contract':  () => {},
    'address':  () => {}
    */
}); };
exports.smartContractAbstractionSemantic = smartContractAbstractionSemantic;
//# sourceMappingURL=semantic.js.map