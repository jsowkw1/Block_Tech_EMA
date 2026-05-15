Compiling 63 files with Solc 0.8.33
Solc 0.8.33 finished in 695.10ms
Compiler run successful!
Analysing contracts...
Running tests...

Ran 16 tests for test/unit/GovernanceToken.t.sol:GovernanceTokenTest
[PASS] test_DelegateToAlice() (gas: 123924)
[PASS] test_DelegateToSelf() (gas: 88972)
[PASS] test_InitialSupply() (gas: 7946)
[PASS] test_MintIncreasesTotalSupply() (gas: 61137)
[PASS] test_NameAndSymbol() (gas: 18765)
[PASS] test_NoVotingPowerWithoutDelegate() (gas: 10728)
[PASS] test_Nonce_StartsAtZero() (gas: 10785)
[PASS] test_OwnerCanMint() (gas: 61974)
[PASS] test_OwnerHasAllTokens() (gas: 10741)
[PASS] test_OwnerIsCorrect() (gas: 10245)
[PASS] test_PastVotesAfterTransfer() (gas: 153997)
[PASS] test_PermitDomainSeparator() (gas: 6039)
[PASS] test_RevertMint_NotOwner() (gas: 14492)
[PASS] test_RevertTransfer_InsufficientBalance() (gas: 17046)
[PASS] test_Transfer() (gas: 50525)
[PASS] test_VotingPowerTransferAfterRedelegate() (gas: 188582)
Suite result: ok. 16 passed; 0 failed; 0 skipped; finished in 7.00ms (4.55ms CPU time)

Ran 3 tests for test/unit/AMM.t.sol:AMMTest
[PASS] testAddLiquidity() (gas: 233370)
[PASS] testRemoveLiquidity() (gas: 206296)
[PASS] testSwap() (gas: 253887)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 6.98ms (3.01ms CPU time)

Ran 4 tests for test/unit/AMMFactory.t.sol:AMMFactoryTest
[PASS] testAllPoolsLength() (gas: 4443110)
[PASS] testCannotCreateDuplicatePool() (gas: 2240601)
[PASS] testCreatePool() (gas: 2237897)
[PASS] testPoolAddressesDiffer() (gas: 4441955)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 75.64ms (7.32ms CPU time)

Ran 2 tests for test/fuzz/AMMFuzz.t.sol:AMMFuzzTest
[PASS] testFuzz_AddLiquidity(uint96,uint96) (runs: 256, μ: 238739, ~: 239527)
[PASS] testFuzz_Swap(uint96,uint96) (runs: 256, μ: 257124, ~: 257534)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 75.64ms (131.32ms CPU time)

Ran 1 test for test/invariant/AMMInvariant.t.sol:AMMInvariantTest
[PASS] invariant_KNeverZero() (runs: 256, calls: 128000, reverts: 128000)

╭----------+-----------------+-------+---------+----------╮
| Contract | Selector        | Calls | Reverts | Discards |
+=========================================================+
| AMM      | addLiquidity    | 42644 | 42644   | 0        |
|----------+-----------------+-------+---------+----------|
| AMM      | removeLiquidity | 42825 | 42825   | 0        |
|----------+-----------------+-------+---------+----------|
| AMM      | swap            | 42531 | 42531   | 0        |
╰----------+-----------------+-------+---------+----------╯

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 3.25s (3.24s CPU time)

Ran 5 test suites in 3.26s (3.42s CPU time): 26 tests passed, 0 failed, 0 skipped (26 total tests)

╭------------------------------------+-----------------+-----------------+---------------+----------------╮
| File                               | % Lines         | % Statements    | % Branches    | % Funcs        |
+=========================================================================================================+
| src/amm/AMM.sol                    | 82.19% (60/73)  | 85.37% (70/82)  | 47.06% (8/17) | 71.43% (5/7)   |
|------------------------------------+-----------------+-----------------+---------------+----------------|
| src/amm/AMMFactory.sol             | 87.50% (14/16)  | 88.89% (16/18)  | 33.33% (1/3)  | 100.00% (2/2)  |
|------------------------------------+-----------------+-----------------+---------------+----------------|
| src/amm/LPToken.sol                | 100.00% (8/8)   | 80.00% (4/5)    | 0.00% (0/1)   | 100.00% (4/4)  |
|------------------------------------+-----------------+-----------------+---------------+----------------|
| src/governance/GovernanceToken.sol | 100.00% (8/8)   | 100.00% (5/5)   | 100.00% (0/0) | 100.00% (4/4)  |
|------------------------------------+-----------------+-----------------+---------------+----------------|
| src/mocks/MockERC20.sol            | 100.00% (2/2)   | 100.00% (1/1)   | 100.00% (0/0) | 100.00% (1/1)  |
|------------------------------------+-----------------+-----------------+---------------+----------------|
| Total                              | 85.98% (92/107) | 86.49% (96/111) | 42.86% (9/21) | 88.89% (16/18) |
╰------------------------------------+-----------------+-----------------+---------------+----------------╯
