import { Context } from '../context';
import { Filter, SubscribeProvider, Subscription, OperationContent } from './interface';
export declare class PollingSubscribeProvider implements SubscribeProvider {
    private context;
    private timer$;
    private newBlock$;
    constructor(context: Context);
    subscribe(_filter: 'head'): Subscription<string>;
    subscribeOperation(filter: Filter): Subscription<OperationContent>;
}
