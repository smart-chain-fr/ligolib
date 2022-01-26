import { MichelsonMap, TezosToolkit } from "@taquito/taquito";
import { InMemorySigner } from "@taquito/signer";
import featurev1 from "./compiled/common/featurev1.json";
import featurev2 from "./compiled/common/featurev2.json";
import proxy from "./compiled/cameligo/basic/proxy.json";

const NODE_URL = "http://localhost:20000";
const Tezos = new TezosToolkit(NODE_URL);
const accounts = {
  alice: {
    pkh: "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
    sk: "edsk3QoqBuvdamxouPhin7swCvkQNgq4jP5KZPbwWNnwdZpSpJiEbq",
  },
  bob: {
    pkh: "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
    sk: "edsk3RFfvaFaxbHx8BMtEW1rKQcPtDML3LXjNqMNLCzC3wLC1bWbAt",
  },
};

const deploy = async () => {
  try {
    const signer = await InMemorySigner.fromSecretKey(accounts.alice.sk);
    Tezos.setProvider({ signer });

    let featurev1Addr: string;
    let featurev2Addr: string;

    {
      console.log("deploying featurev1 contract...");
      const op = await Tezos.contract.originate({
        code: featurev1,
        storage: 0,
      });
      await op.confirmation();
      featurev1Addr = op.contractAddress;
      console.log(`[OK] ${featurev1Addr}`);
    }

    {
      console.log("deploying featurev2 contract...");
      const op = await Tezos.contract.originate({
        code: featurev2,
        storage: MichelsonMap.fromLiteral({ [accounts.bob.pkh]: 2 }),
      });
      await op.confirmation();
      featurev2Addr = op.contractAddress;
      console.log(`[OK] ${featurev2Addr}`);
    }

    {
      console.log("deploying basic proxy contract...");
      const op = await Tezos.contract.originate({
        code: proxy,
        storage: {
          owner: accounts.alice.pkh,
          version: "featurev1",
          versions: MichelsonMap.fromLiteral({
            featurev1: featurev1Addr,
            featurev2: featurev2Addr,
          }),
        },
      });
      await op.confirmation();
      console.log(`[OK] ${op.contractAddress}`);
    }
  } catch (e) {
    console.log(e);
  }
};

deploy();
