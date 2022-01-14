export declare class InvalidParameterError implements Error {
    smartContractMethodName: string;
    sigs: any[];
    args: any[];
    name: string;
    message: string;
    constructor(smartContractMethodName: string, sigs: any[], args: any[]);
}
export declare class UndefinedLambdaContractError implements Error {
    name: string;
    message: string;
    constructor();
}
export declare class InvalidDelegationSource implements Error {
    source: string;
    name: string;
    message: string;
    constructor(source: string);
}
export declare class InvalidCodeParameter implements Error {
    message: string;
    readonly data: any;
    name: string;
    constructor(message: string, data: any);
}
export declare class InvalidInitParameter implements Error {
    message: string;
    readonly data: any;
    name: string;
    constructor(message: string, data: any);
}
