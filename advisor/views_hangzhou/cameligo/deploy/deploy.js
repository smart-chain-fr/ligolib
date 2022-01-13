"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
exports.__esModule = true;
var signer_1 = require("@taquito/signer");
var taquito_1 = require("@taquito/taquito");
var advisor_json_1 = __importDefault(require("../compiled/advisor.json"));
var indice_json_1 = __importDefault(require("../compiled/indice.json"));
var dotenv = __importStar(require("dotenv"));
dotenv.config(({ path: __dirname + '/.env' }));
var rpc = process.env.RPC; //"http://127.0.0.1:8732"
var pk = process.env.ADMIN_PK || undefined;
var Tezos = new taquito_1.TezosToolkit(rpc);
var signer = new signer_1.InMemorySigner(pk);
Tezos.setProvider({ signer: signer });
var admin = process.env.ADMIN_ADDRESS;
var indice_address = process.env.INDICE_CONTRACT_ADDRESS || undefined;
var advisor_address = process.env.ADVISOR_CONTRACT_ADDRESS || undefined;
var indice_initial_value = 4;
var advisor_initial_result = false;
//const lambda_algorithm_michelson = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"
var lambda_algorithm = '[{"prim": "PUSH", "args": [{"prim": "int"}, {"int": "10"}]}, {"prim": "SWAP"}, {"prim": "COMPARE"}, {"prim": "LT"}, {"prim": "IF", "args": [    [{"prim": "PUSH", "args": [{"prim": "bool"}, {"prim": "True"}]}],     [{"prim": "PUSH", "args": [{"prim": "bool"}, {"prim": "False"}]}]    ]}]';
function orig() {
    return __awaiter(this, void 0, void 0, function () {
        var indice_store, advisor_store, indice_originated, advisor_originated, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    indice_store = indice_initial_value;
                    advisor_store = {
                        'indiceAddress': indice_address,
                        'algorithm': JSON.parse(lambda_algorithm),
                        'result': advisor_initial_result
                    };
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 7, , 8]);
                    if (!(indice_address === undefined)) return [3 /*break*/, 4];
                    return [4 /*yield*/, Tezos.contract.originate({
                            code: indice_json_1["default"],
                            storage: indice_store
                        })];
                case 2:
                    indice_originated = _a.sent();
                    console.log("Waiting for INDICE " + indice_originated.contractAddress + " to be confirmed...");
                    return [4 /*yield*/, indice_originated.confirmation(2)];
                case 3:
                    _a.sent();
                    console.log('confirmed INDICE: ', indice_originated.contractAddress);
                    indice_address = indice_originated.contractAddress;
                    advisor_store.indiceAddress = indice_address;
                    _a.label = 4;
                case 4: return [4 /*yield*/, Tezos.contract.originate({
                        code: advisor_json_1["default"],
                        storage: advisor_store
                    })];
                case 5:
                    advisor_originated = _a.sent();
                    console.log("Waiting for ADVISOR " + advisor_originated.contractAddress + " to be confirmed...");
                    return [4 /*yield*/, advisor_originated.confirmation(2)];
                case 6:
                    _a.sent();
                    console.log('confirmed ADVISOR: ', advisor_originated.contractAddress);
                    advisor_address = advisor_originated.contractAddress;
                    console.log("./tezos-client remember contract INDICE", indice_address);
                    console.log("./tezos-client remember contract ADVISOR", advisor_address);
                    console.log("tezos-client transfer 0 from ", admin, " to ", advisor_address, " --entrypoint \"executeAlgorithm\" --arg \"Unit\"");
                    return [3 /*break*/, 8];
                case 7:
                    error_1 = _a.sent();
                    console.log(error_1);
                    return [3 /*break*/, 8];
                case 8: return [2 /*return*/];
            }
        });
    });
}
orig();
