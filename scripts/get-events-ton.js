const { TonClient, abiContract, signerKeys } = require("@tonclient/core");
const { libNode } = require("@tonclient/lib-node");
const { Account } = require("@tonclient/appkit");
const { TestContractContract } = require("../ton-packages/TestContract.js");

const dotenv = require('dotenv').config();
const networks = ["http://localhost",'net1.ton.dev','main.ton.dev','rustnet.ton.dev','https://gql.custler.net'];
const hello = ["Hello localhost TON!","Hello dev net TON!","Hello main net TON!","Hello rust dev net TON!","Hello fld dev net TON!"];
const networkSelector = process.env.NET_SELECTOR;

const zeroAddress = '0:0000000000000000000000000000000000000000000000000000000000000000';

TonClient.useBinaryLibrary(libNode);

async function logEvents(params, response_type) {
    // console.log(`params = ${JSON.stringify(params, null, 2)}`);
    // console.log(`response_type = ${JSON.stringify(response_type, null, 2)}`);
}

async function main(client) {

    let response;

    const TestContractAddr = "0:2b0b50e1c25f797c73cd9d776ea0265b1336952dcf490fc262d538ec8815cfa6";

    const TestContractAcc = new Account(TestContractContract, {address:TestContractAddr,client,});
    response = await TestContractAcc.runLocal("countEventEmit", {});
    console.log(response.decoded.output);


    const result = (await client.net.query_collection({
        collection: "messages",
        filter: {
            src: {
                eq: TestContractAddr,
            },
            msg_type:{ eq:2 }
        },
        result: "boc",
    })).result;

    console.log(result);

    const decoded = await client.abi.decode_message({
        abi: abiContract(TestContractContract.abi),
        message: result[0].boc,
    });

    console.log(decoded);

    const result1 = (await client.net.query_collection({
        collection: "messages",
        filter: {
            src: {
                eq: TestContractAddr,
            },
            msg_type:{ eq:2 }
        },
        result: "body",
    })).result;

    console.log(result1);

    const decoded1 = await client.abi.decode_message_body({
        abi: abiContract(TestContractContract.abi),
        body: result1[0].body,
        is_internal: false
    });

    console.log(decoded1);

}

(async () => {
    const client = new TonClient({network: { endpoints: [networks[networkSelector]],},});
    try {
        console.log(hello[networkSelector]);
        await main(client);
        process.exit(0);
    } catch (error) {
        if (error.code === 504) {
            console.error(`Network is inaccessible. Pls check connection`);
        } else {
            console.error(error);
        }
    }
    client.close();
})();
