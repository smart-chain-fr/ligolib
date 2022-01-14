import { OperationEmitter } from '../operations/operation-emitter';
import { DelegateParams, OriginateParams, ParamsWithKind, RegisterDelegateParams, TransferParams, RevealParams } from '../operations/types';
import { Estimate } from './estimate';
import { EstimationProvider } from './interface';
export declare class RPCEstimateProvider extends OperationEmitter implements EstimationProvider {
    private readonly ALLOCATION_STORAGE;
    private readonly ORIGINATION_STORAGE;
    private readonly OP_SIZE_REVEAL;
    private getAccountLimits;
    private ajustGasForBatchOperation;
    private getEstimationPropertiesFromOperationContent;
    private prepareEstimate;
    /**
     *
     * @description Estimate gasLimit, storageLimit and fees for an origination operation
     *
     * @returns An estimation of gasLimit, storageLimit and fees for the operation
     *
     * @param OriginationOperation Originate operation parameter
     */
    originate({ fee, storageLimit, gasLimit, ...rest }: OriginateParams): Promise<Estimate>;
    /**
     *
     * @description Estimate gasLimit, storageLimit and fees for an transfer operation
     *
     * @returns An estimation of gasLimit, storageLimit and fees for the operation
     *
     * @param TransferOperation Originate operation parameter
     */
    transfer({ fee, storageLimit, gasLimit, ...rest }: TransferParams): Promise<Estimate>;
    /**
     *
     * @description Estimate gasLimit, storageLimit and fees for a delegate operation
     *
     * @returns An estimation of gasLimit, storageLimit and fees for the operation
     *
     * @param Estimate
     */
    setDelegate({ fee, gasLimit, storageLimit, ...rest }: DelegateParams): Promise<Estimate>;
    /**
     *
     * @description Estimate gasLimit, storageLimit and fees for a each operation in the batch
     *
     * @returns An array of Estimate objects. If a reveal operation is needed, the first element of the array is the Estimate for the reveal operation.
     */
    batch(params: ParamsWithKind[]): Promise<Estimate[]>;
    /**
     *
     * @description Estimate gasLimit, storageLimit and fees for a delegate operation
     *
     * @returns An estimation of gasLimit, storageLimit and fees for the operation
     *
     * @param Estimate
     */
    registerDelegate(params: RegisterDelegateParams): Promise<Estimate>;
    /**
     *
     * @description Estimate gasLimit, storageLimit and fees to reveal the current account
     *
     * @returns An estimation of gasLimit, storageLimit and fees for the operation or undefined if the account is already revealed
     *
     * @param Estimate
     */
    reveal(params?: RevealParams): Promise<Estimate | undefined>;
    private addRevealOp;
}
