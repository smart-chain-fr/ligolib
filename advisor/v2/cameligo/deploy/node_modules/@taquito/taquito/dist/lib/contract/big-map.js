"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BigMapAbstraction = void 0;
var http_utils_1 = require("@taquito/http-utils");
var BigMapAbstraction = /** @class */ (function () {
    function BigMapAbstraction(id, schema, provider) {
        this.id = id;
        this.schema = schema;
        this.provider = provider;
    }
    /**
     *
     * @description Fetch one value in a big map
     *
     * @param keysToEncode Key to query (will be encoded properly according to the schema)
     * @param block optional block level to fetch the values from (head will be use by default)
     * @returns Return a well formatted json object of a big map value or undefined if the key is not found in the big map
     *
     */
    BigMapAbstraction.prototype.get = function (keyToEncode, block) {
        return __awaiter(this, void 0, void 0, function () {
            var id, e_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, this.provider.getBigMapKeyByID(this.id.toString(), keyToEncode, this.schema, block)];
                    case 1:
                        id = _a.sent();
                        return [2 /*return*/, id];
                    case 2:
                        e_1 = _a.sent();
                        if (e_1 instanceof http_utils_1.HttpResponseError && e_1.status === http_utils_1.STATUS_CODE.NOT_FOUND) {
                            return [2 /*return*/, undefined];
                        }
                        else {
                            throw e_1;
                        }
                        return [3 /*break*/, 3];
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    /**
     *
     * @description Fetch multiple values in a big map
     * All values will be fetched on the same block level. If a block is specified in the request, the values will be fetched at it.
     * Otherwise, a first request will be done to the node to fetch the level of the head and all values will be fetched at this level.
     * If one of the keys does not exist in the big map, its value will be set to undefined.
     *
     * @param keysToEncode Array of keys to query (will be encoded properly according to the schema)
     * @param block optional block level to fetch the values from
     * @param batchSize optional batch size representing the number of requests to execute in parallel
     * @returns A MichelsonMap containing the keys queried in the big map and their value in a well-formatted JSON object format
     *
     */
    BigMapAbstraction.prototype.getMultipleValues = function (keysToEncode, block, batchSize) {
        if (batchSize === void 0) { batchSize = 5; }
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                return [2 /*return*/, this.provider.getBigMapKeysByID(this.id.toString(), keysToEncode, this.schema, block, batchSize)];
            });
        });
    };
    BigMapAbstraction.prototype.toJSON = function () {
        return this.id.toString();
    };
    BigMapAbstraction.prototype.toString = function () {
        return this.id.toString();
    };
    return BigMapAbstraction;
}());
exports.BigMapAbstraction = BigMapAbstraction;
//# sourceMappingURL=big-map.js.map