# Intent Hub - README

## Overview

**Intent Hub** is a Clarity smart contract that serves as a routing layer for intent-based transactions on Stacks. It enables decentralized intent declaration and execution tracking through an approved executor network.

## Features

- **Intent Declaration**: Users can declare intents targeting any contract function with parameter hashing
- **Executor Management**: Owner-controlled whitelist of approved relayers/bots authorized to execute intents
- **Execution Tracking**: Built-in state management to prevent double-execution and track intent lifecycle
- **Permission Control**: Role-based access (Owner and Executor) with comprehensive error handling

## Architecture

### Storage Maps

- **executors**: Principal → Boolean mapping of approved executor addresses
- **intents**: Uint → Intent record mapping storing full intent metadata
- **intent-nonce**: Auto-incrementing counter for unique intent IDs

### Intent Structure

```
{
  owner: principal,           // Intent creator
  target: principal,          // Target contract address
  function: string-ascii 32,  // Target function name
  params-hash: buff 32,       // Hash of parameters for verification
  executed: bool,             // Execution status flag
  created-at: uint            // Timestamp (reserved for future use)
}
```

## Key Functions

### Owner Controls
- `add-executor(executor)` - Whitelist a new executor
- `remove-executor(executor)` - Remove executor privileges

### Intent Operations
- `create-intent(target, function-name, params-hash)` - Declare a new intent
- `mark-executed(intent-id)` - Mark intent as executed (executor only)
- `get-intent(intent-id)` - Retrieve intent details

## Error Codes

| Code | Error | Meaning |
|------|-------|---------|
| u20001 | ERR-NOT-OWNER | Caller is not the contract owner |
| u20002 | ERR-NOT-EXECUTOR | Caller is not an approved executor |
| u20003 | ERR-INTENT-NOT-FOUND | Intent ID does not exist |
| u20004 | ERR-ALREADY-DONE | Intent has already been executed |

## Usage Example

```clarity
;; 1. Owner adds an executor (bot/relayer)
(contract-call? .intent-hub add-executor 'ST1H5R2JA9F7G7K8L9...)

;; 2. User creates an intent
(contract-call? .intent-hub create-intent
  'ST2XYZ... ;; target contract
  "transfer" ;; function name
  0x1234...) ;; params hash

;; 3. Executor marks it as executed
(contract-call? .intent-hub mark-executed u1) ;; intent-id
```

## License

[Specify your license here]
