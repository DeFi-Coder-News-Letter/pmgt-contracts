module.exports = {
    // Configure explicit Ethereum networks
    networks: {},

    // Configure your compilers
    compilers: {
        solc: {
            // Using native c++ compiler, which should be installed as version 0.4.24
            version: "native",

            // Uncomment to use Truffle default compiler (solc-js) with version 0.4.24
            // version: "0.4.24",

            // Uncomment to use version 0.4.24 you've installed locally with docker (default: false)
            // docker: true,

            // See the solidity docs for advice about optimization and evmVersion
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 2000
                },
                evmVersion: "byzantium"
            }
        }
    }
};