(async () => {
    try {
        let addrFreeTon = '0xb8a0ef7edc5fd1e2c724451ae861d3203a80a4c7efc7002b5917f4c3dc35a610';
        const packedArgs = web3.eth.abi.encodeParameters(['uint8', 'uint256'],['0', addrFreeTon]);
        console.log(packedArgs);
        // const contractName = 'Deposit'
        // const artifactsPath = `browser/artifacts/${contractName}.json` // Change this for different path

        // const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

        // const contractAddress = '0x76a71fdb1c4e7fe766684e2634bea1f34a869c73'

        // var myContract = new web3.eth.Contract(metadata, contractAddress);

        // myContract.getPastEvents('Deposit', {
        //     fromBlock: 0,
        //     toBlock: 'latest'
        // }, function(error, events){
        //     // console.log(events);
        // })
        // .then(function(events){
        //     console.log(events) // same results as the optional callback above
        // });

        const contractName = 'TransferNftProxy'
        const artifactsPath = `browser/artifacts/${contractName}.json` // Change this for different path

        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

        const contractAddress = '0x04fEeB0BaCCCC6473d8B0b074b4BB1B109d9f4f2'

        var myContract = new web3.eth.Contract(metadata.abi, contractAddress);

        myContract.getPastEvents('EthereumTransferNft', {
            fromBlock: 11365976,
            toBlock: 'latest'
        }, function(error, events){
            // console.log(events);
        })
            .then(function(events){
                console.log(events) // same results as the optional callback above
            });

    } catch (e) {
        console.log(e.message)
    }
})()
