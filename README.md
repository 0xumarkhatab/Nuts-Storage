# Nuts Storage Development guide

This is a guide on how to setup the entire fullstack flow of the NutsStorage contract.

Let's explore the different Layers our system will be composed of.

## 1. Smart Contract Layer

### Project Setup and Development  
- **Environment:**  
  • We use Foundry as our smart contracts development framework so feel free to install from here : [Foundry](https://book.getfoundry.sh/getting-started/installation).  
  • Install OpenZeppelin dependencies like oz-contracts and oz upgradable contracts so our contract inherits secure, audited functionality. Forge build will do that.

- **Contract Features:**  
  • The contract, `NutsStorage.sol`, is upgradeable (using the `UUPS` pattern), `PausableUpgradable`, and includes access control via `OwnableUpgradable`.  
  • It defines an `“important”` state variable and a mapping of `authorized users`.  
  • Only the `owner` can `add authorized users`, and only those authorized users can update the state of `important` variable.  
  • The contract includes an `initializer` function for `upgradeable` deployments, as well as pause and unpause functions to disable functionality in emergencies.  
  • The `_authorizeUpgrade` function restricts upgrades to the owner.

### Testing
Tests are written in `tests/` dir and can be easily run using `forge test`


### Deployment  

- **Deployment:**  
  • Configure Foundry to deploy to the Sepolia testnet by setting the appropriate `RPC URL` and deployer keys.  
  • Run your deployment scripts, and verify the contract on a block explorer to ensure transparency and future upgrade capability.

---

## 2. Backend API and Indexer with Node.js, Express, and MongoDB

### Backend Purpose and Architecture  
- **API Server:**  
  • Build a `Node.js` backend using Express to serve as the bridge between your smart contract and your frontend.  
  • This server exposes RESTful endpoints for external clients to query on‑chain state and indexed event data.
  
- **Event Indexer:**  
  • Use `ethers.js` in your backend to listen for events emitted by the contract (for example, the `UserAuthorized` event).  
  • When such an event is detected, capture its data (e.g., the authorized user’s address, transaction hash, block number, and timestamp) and store it in a MongoDB database.
  • `MongoDB` serves as your primary source for indexing, enabling fast and flexible queries by the frontend.

### REST API Endpoints  
- **Data Retrieval:**  
  • Design API routes to fetch indexed events (e.g., all events, or details by event ID).  
  • Optionally, include endpoints to retrieve current on‑chain state (like the “important” value) if needed.

---

## 3. Frontend Development with React, Wagmi, Wallet Connect, and Chakra UI

### User Interface and Wallet Connectivity  
- **Framework and Libraries:**  
  • Create a `React` application for the frontend.  
  • Use `Chakra UI` for a modern, responsive design.  
  • Integrate wallet connectivity using the `wagmi toolkit`, which supports `Wallet Connect` and other popular wallet providers.
  
- **User Interactions:**  
  • Provide components that allow users to connect their wallets and display their wallet address upon connection.  
  • Enable authorized users to interact with the contract—such as updating the `“important”` variable—directly from the UI.

---

## 4. CI/CD with GitHub Actions

### Automated Testing and Deployment  
- **Workflow Configuration:**  
  • Set up `GitHub Actions` workflows to automate the building, testing, and deployment of both the backend and frontend.  
  • Ensure your CI pipeline runs 

  - smart contract tests (using Foundry),
  - backend tests (for Node.js/Express)
  -  frontend tests (for React).
  
- **Docker Integration:**  
  • Include steps in your workflows to build Docker images for each component.  
  • Automate the process of pushing these images to your container registry and triggering deployments as needed.

---

## 5. Containerization with Docker and Docker Compose

### Dockerizing Your Services  
- **Backend Container:**  
  • Create a Docker container for the Node.js backend. The container should install dependencies, run your server, and be configured with environment variables (e.g., MongoDB URI, Sepolia RPC URL, contract address).
  
- **Frontend Container:**  
  • Create a Docker container for your React frontend. Typically, the app is built and then served using a lightweight web server (like Nginx).
  
- **Database Container:**  
  • Use the official MongoDB Docker image to run your database in a container.
  
---

## Final Integration and Deployment

1. **Smart Contract:**  
   - Develop, test, and deploy your upgradeable and pausable contract on the Sepolia testnet with Foundry.
2. **Backend & Indexing:**  
   - Build an Express server that listens to contract events and indexes them in MongoDB.  
   - Expose RESTful endpoints for event data retrieval.
3. **Frontend:**  
   - Create a React app with Chakra UI and wallet integration via wagmi, allowing users to connect their wallet and interact with the contract, while displaying indexed events.
4. **CI/CD:**  
   - Automate builds, tests, and Docker image creation using GitHub Actions.
5. **Containerization:**  
   - Use Docker and Docker Compose to run your backend, frontend, and MongoDB as isolated, easily deployable services.