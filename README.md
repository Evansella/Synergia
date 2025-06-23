# Synergia - Autonomous Blockchain Knowledge Investment Smart Contract

A decentralized smart contract built on the Stacks blockchain for crowdfunding research studies and knowledge projects. Synergia enables researchers to propose studies, receive community funding, and manage project lifecycles transparently on-chain.

## Overview

Synergia creates a trustless platform where:
- Researchers can propose studies with funding targets
- Community members can contribute STX tokens to support research
- Project progress is tracked transparently on the blockchain
- Funds are managed autonomously through smart contract logic

## Features

- **Study Proposals**: Submit research proposals with titles, descriptions, and funding targets
- **Crowdfunding**: Community-driven funding with automatic target tracking
- **Lifecycle Management**: Track projects from active to funded to completed states
- **Transparent Ledger**: All transactions and project states recorded on-chain
- **Input Validation**: Comprehensive parameter checking for security

## Contract Architecture

### State Management
The contract manages three distinct states for each study:
- `STATE-ACTIVE` (0): Study is open for funding
- `STATE-COMPLETE-FUNDED` (1): Funding target reached
- `STATE-FINISHED` (2): Study marked as completed by originator

### Data Structures

#### Study Ledger
Each study record contains:
```clarity
{
  originator: principal,      // Address of study proposer
  title: (string-utf8 100),   // Study title (max 100 chars)
  description: (string-utf8 500), // Study description (max 500 chars)
  target-amount: uint,        // Funding goal in microSTX
  current-total: uint,        // Current funding amount
  status: uint               // Current state (0, 1, or 2)
}
```

## Public Functions

### `propose-study`
Submit a new research study proposal.

**Parameters:**
- `title`: Study title (1-100 UTF-8 characters)
- `description`: Detailed description (1-500 UTF-8 characters)
- `target-amount`: Funding goal in microSTX (must be > 0)

**Returns:** Record ID of the created study

**Example:**
```clarity
(contract-call? .synergia propose-study 
  u"Climate Change Impact Study" 
  u"Comprehensive analysis of climate change effects on coastal ecosystems"
  u1000000) ;; 1 STX in microSTX
```

### `fund-proposal`
Contribute STX tokens to fund a study proposal.

**Parameters:**
- `record-id`: ID of the study to fund
- `contribution`: Amount in microSTX to contribute

**Returns:** Boolean success indicator

**Requirements:**
- Study must be in ACTIVE state
- Contribution cannot exceed remaining funding needed
- Caller must have sufficient STX balance

**Example:**
```clarity
(contract-call? .synergia fund-proposal u1 u500000) ;; Fund 0.5 STX
```

### `complete-study`
Mark a fully-funded study as completed (originator only).

**Parameters:**
- `record-id`: ID of the study to mark complete

**Returns:** Boolean success indicator

**Requirements:**
- Only the study originator can call this function
- Study must be in COMPLETE-FUNDED state

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `ERR-UNAUTHORIZED-ACTION` | Caller not authorized for this action |
| u101 | `ERR-INSUFFICIENT-BALANCE` | Insufficient funds or exceeds target |
| u102 | `ERR-RECORD-NOT-FOUND` | Study record does not exist |
| u103 | `ERR-INVALID-PARAMETER` | Invalid input parameter |

## Usage Examples

### Complete Workflow

1. **Propose a Study:**
```clarity
;; Researcher proposes a new study
(contract-call? .synergia propose-study 
  u"AI Ethics Research" 
  u"Investigating ethical implications of artificial intelligence in healthcare"
  u5000000) ;; Target: 5 STX
;; Returns: (ok u1) - Study ID 1 created
```

2. **Fund the Study:**
```clarity
;; Community member 1 contributes
(contract-call? .synergia fund-proposal u1 u2000000) ;; 2 STX
;; Returns: (ok true)

;; Community member 2 contributes
(contract-call? .synergia fund-proposal u1 u3000000) ;; 3 STX
;; Returns: (ok true) - Study now fully funded
```

3. **Complete the Study:**
```clarity
;; Original researcher marks study complete
(contract-call? .synergia complete-study u1)
;; Returns: (ok true)
```

## Security Features

- **Input Validation**: All parameters are validated before processing
- **Access Control**: Only study originators can mark studies complete
- **Overflow Protection**: Contributions cannot exceed funding targets
- **State Management**: Proper state transitions prevent invalid operations
- **Range Checking**: Record IDs are validated against existing records

## Deployment

### Prerequisites
- Stacks blockchain environment
- Clarity CLI tools
- STX tokens for deployment and testing

### Deploy Steps
1. Compile the contract:
```bash
clarinet check
```

2. Deploy to testnet:
```bash
clarinet deploy --testnet
```

3. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## Development

### Testing
Run the test suite:
```bash
clarinet test
```

### Local Development
Start local development environment:
```bash
clarinet integrate
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request
