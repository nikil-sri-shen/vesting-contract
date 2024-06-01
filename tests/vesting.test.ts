import { Cl } from "@stacks/transactions";
import { describe, expect, it } from "vitest";
import { aD } from "vitest/dist/reporters-yx5ZTtEV.js";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const address1 = accounts.get("wallet_1")!;

/*
  The test below is an example. To learn more, read the testing documentation here:
  https://docs.hiro.so/clarinet/feature-guides/test-contract-with-clarinet-sdk
*/

describe("Testing FT minting", () => {
  it("ensures ft is minted", () => {
    const result = simnet.callPublicFn(
      "magic-beans",
      "mint",
      [Cl.uint(10000)],
      deployer
    );
    expect(result.result).toBeOk(Cl.bool(true));
    expect(result.events).toHaveLength(1);
    // console.log(result.events);
    expect(result.events[0].event).toBe("ft_mint_event");
    expect(result.events[0].data).toMatchObject({
      amount: "10000",
      asset_identifier:
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.magic-beans::magic-beans",
      recipient: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
    });
  });
  it("ensures ft is not minted if amount is 0 or less", () => {
    const result = simnet.callPublicFn(
      "magic-beans",
      "mint",
      [Cl.uint(0)],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(102));
  });
});

describe("Testing FT transfer", () => {
  it("ensures ft is transfered", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    const result = simnet.callPublicFn(
      "magic-beans",
      "transfer",
      [
        Cl.uint(1000),
        Cl.principal(deployer),
        Cl.principal(address1),
        Cl.none(),
      ],
      deployer
    );
    expect(result.result).toBeOk(Cl.bool(true));
    expect(result.events).toHaveLength(1);
    // console.log(result.events);
    expect(result.events[0].event).toBe("ft_transfer_event");
    expect(result.events[0].data).toMatchObject({
      amount: "1000",
      asset_identifier:
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.magic-beans::magic-beans",
      recipient: "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5",
      sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
    });
  });
  it("ensures ft is not transfered if amount is 0 or less", () => {
    const result = simnet.callPublicFn(
      "magic-beans",
      "transfer",
      [Cl.uint(0), Cl.principal(deployer), Cl.principal(address1), Cl.none()],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(102));
  });
});

describe("Testing other FT functions", () => {
  it("Get symbol", () => {
    const result = simnet.callReadOnlyFn(
      "magic-beans",
      "get-symbol",
      [],
      deployer
    );
    expect(result.result).toBeOk(Cl.stringAscii("MAGIC"));
  });
  it("Get decimals", () => {
    const result = simnet.callReadOnlyFn(
      "magic-beans",
      "get-decimals",
      [],
      deployer
    );
    expect(result.result).toBeOk(Cl.uint(6));
  });
  it("Get name", () => {
    const result = simnet.callReadOnlyFn(
      "magic-beans",
      "get-name",
      [],
      deployer
    );
    expect(result.result).toBeOk(Cl.stringAscii("magic-beans"));
  });
  it("Get Token URI", () => {
    const result = simnet.callReadOnlyFn(
      "magic-beans",
      "get-token-uri",
      [],
      deployer
    );
    expect(result.result).toBeOk(Cl.none());
  });
  it("Get Total Supply", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    const result = simnet.callReadOnlyFn(
      "magic-beans",
      "get-total-supply",
      [],
      deployer
    );
    expect(result.result).toBeOk(Cl.uint(10000));
  });
  it("Get Balance", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    const result = simnet.callReadOnlyFn(
      "magic-beans",
      "get-balance",
      [Cl.principal(deployer)],
      deployer
    );
    expect(result.result).toBeOk(Cl.uint(10000));
  });
});

describe("Testing NFT minting", () => {
  it("ensures nft is minted", () => {
    const result = simnet.callPublicFn("ape", "mint", [], deployer);
    expect(result.result).toBeOk(Cl.uint(1));
    expect(result.events).toHaveLength(1);
    // console.log(result.events);
    expect(result.events[0].event).toBe("nft_mint_event");
    expect(result.events[0].data).toMatchObject({
      asset_identifier: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.ape::ape",
      raw_value: "0x0100000000000000000000000000000001",
      recipient: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
      value: {
        type: 1,
        value: 1n,
      },
    });
  });
});

describe("Testing NFT transfer", () => {
  it("ensures nft is transfered", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callPublicFn(
      "ape",
      "transfer",
      [Cl.uint(1), Cl.principal(deployer), Cl.principal(address1)],
      deployer
    );
    expect(result.result).toBeOk(Cl.bool(true));
    expect(result.events).toHaveLength(1);
    // console.log(result.events);
    expect(result.events[0].event).toBe("nft_transfer_event");
    expect(result.events[0].data).toMatchObject({
      asset_identifier: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.ape::ape",
      raw_value: "0x0100000000000000000000000000000001",
      recipient: "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5",
      sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
      value: {
        type: 1,
        value: 1n,
      },
    });
  });
});

describe("Testing other FT functions", () => {
  it("Get Token URI", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callReadOnlyFn(
      "ape",
      "get-token-uri",
      [Cl.uint(1)],
      deployer
    );
    expect(result.result).toBeOk(Cl.none());
  });
  it("Get Last token id", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callReadOnlyFn(
      "ape",
      "get-last-token-id",
      [],
      deployer
    );
    expect(result.result).toBeOk(Cl.uint(1));
  });
  it("Get Owner", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callReadOnlyFn(
      "ape",
      "get-owner",
      [Cl.uint(1)],
      deployer
    );
    expect(result.result).toBeOk(Cl.some(Cl.principal(deployer)));
  });
});

describe("Testing FT Lock function", () => {
  it("ensures ft is locked", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    const result = simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(1000),
        Cl.uint(1),
      ],
      deployer
    );
    expect(result.result).toBeOk(Cl.uint(1));
    // console.log(result.events);
    expect(result.events).toHaveLength(1);
    expect(result.events[0].event).toBe("ft_transfer_event");
    expect(result.events[0].data).toMatchObject({
      amount: "1000",
      asset_identifier:
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.magic-beans::magic-beans",
      recipient: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting",
      sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
    });
  });
  it("ensures ft is not locked if amount <= 0", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    const result = simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(0),
        Cl.uint(1),
      ],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(102));
  });
  it("ensures ft is not locked if expiry <= 0", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    const result = simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(1000),
        Cl.uint(0),
      ],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(105));
  });
});

describe("Testing NFT Lock function", () => {
  it("ensures nft is locked", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callPublicFn(
      "vesting",
      "lock-nft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(1),
        Cl.uint(1),
      ],
      deployer
    );
    expect(result.result).toBeOk(Cl.uint(1));
    // console.log(result.events);
    expect(result.events).toHaveLength(1);
    expect(result.events[0].event).toBe("nft_transfer_event");
    expect(result.events[0].data).toMatchObject({
      asset_identifier: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.ape::ape",
      raw_value: "0x0100000000000000000000000000000001",
      recipient: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting",
      sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
      value: {
        type: 1,
        value: 1n,
      },
    });
  });
  it("ensures nft is not locked if id not present", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callPublicFn(
      "vesting",
      "lock-nft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(2),
        Cl.uint(1),
      ],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(101));
  });
  it("ensures nft is not locked if expiry <= 0", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    const result = simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(1),
        Cl.uint(0),
      ],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(105));
  });
});

describe("Testing FT Claim function", () => {
  it("ensures ft is claimed", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(1000),
        Cl.uint(1),
      ],
      deployer
    );
    simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-ft",
      [Cl.contractPrincipal(deployer, "magic-beans"), Cl.uint(1)],
      address1
    );
    expect(result.result).toBeOk(Cl.uint(1));
    // console.log(result.events);
    expect(result.events).toHaveLength(1);
    expect(result.events[0].event).toBe("ft_transfer_event");
    expect(result.events[0].data).toMatchObject({
      amount: "1000",
      asset_identifier:
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.magic-beans::magic-beans",
      recipient: "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5",
      sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting",
    });
  });
  it("ensures ft is not claimed if data not found", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(1000),
        Cl.uint(1),
      ],
      deployer
    );
    simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-ft",
      [Cl.contractPrincipal(deployer, "magic-beans"), Cl.uint(2)],
      address1
    );
    expect(result.result).toBeErr(Cl.uint(101));
  });
  it("ensures ft is not claimed if claimer in not tx sender", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(1000),
        Cl.uint(1),
      ],
      deployer
    );
    simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-ft",
      [Cl.contractPrincipal(deployer, "magic-beans"), Cl.uint(1)],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(103));
  });
  it("ensures ft is not claimed if height is not reached", () => {
    simnet.callPublicFn("magic-beans", "mint", [Cl.uint(10000)], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-ft",
      [
        Cl.contractPrincipal(deployer, "magic-beans"),
        Cl.principal(address1),
        Cl.uint(1000),
        Cl.uint(1),
      ],
      deployer
    );
    // simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-ft",
      [Cl.contractPrincipal(deployer, "magic-beans"), Cl.uint(1)],
      address1
    );
    expect(result.result).toBeErr(Cl.uint(104));
  });
});

describe("Testing NFT Claim function", () => {
  it("ensures nft is claimed", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-nft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(1),
        Cl.uint(1),
      ],
      deployer
    );
    simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-nft",
      [Cl.contractPrincipal(deployer, "ape"), Cl.uint(1)],
      address1
    );
    expect(result.result).toBeOk(Cl.uint(1));
    // console.log(result.events);
    expect(result.events).toHaveLength(1);
    expect(result.events[0].event).toBe("nft_transfer_event");
    expect(result.events[0].data).toMatchObject({
      asset_identifier: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.ape::ape",
      raw_value: "0x0100000000000000000000000000000001",
      recipient: "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5",
      sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting",
      value: {
        type: 1,
        value: 1n,
      },
    });
  });
  it("ensures nft is not claimed if data not found", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-nft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(1),
        Cl.uint(1),
      ],
      deployer
    );
    simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-nft",
      [Cl.contractPrincipal(deployer, "ape"), Cl.uint(2)],
      address1
    );
    expect(result.result).toBeErr(Cl.uint(101));
  });
  it("ensures nft is not claimed if claimer is not tx-sender", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-nft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(1),
        Cl.uint(1),
      ],
      deployer
    );
    simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-nft",
      [Cl.contractPrincipal(deployer, "ape"), Cl.uint(1)],
      deployer
    );
    expect(result.result).toBeErr(Cl.uint(103));
  });
  it("ensures nft is not claimed if height not reached", () => {
    simnet.callPublicFn("ape", "mint", [], deployer);
    simnet.callPublicFn(
      "vesting",
      "lock-nft",
      [
        Cl.contractPrincipal(deployer, "ape"),
        Cl.principal(address1),
        Cl.uint(1),
        Cl.uint(1),
      ],
      deployer
    );
    // simnet.mineEmptyBlocks(200);
    const result = simnet.callPublicFn(
      "vesting",
      "claim-nft",
      [Cl.contractPrincipal(deployer, "ape"), Cl.uint(1)],
      address1
    );
    expect(result.result).toBeErr(Cl.uint(104));
  });
});
