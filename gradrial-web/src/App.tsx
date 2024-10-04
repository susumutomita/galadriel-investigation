import React, { useEffect, useState } from 'react';
import { Interface, ethers } from 'ethers';
import ChatGptABI from './abi/ChatGptABI.json';
import './App.css';

const contractABI = new Interface(ChatGptABI);
const contractAddress = '0x89cbf47222884c74344Fd8669a21bb88001d873e';

function App() {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [signer, setSigner] = useState<ethers.JsonRpcSigner | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [message, setMessage] = useState('');
  const [chatHistory, setChatHistory] = useState<string[]>([]);

  useEffect(() => {
    const initWeb3 = async () => {
      if ((window as any).ethereum) {
        await (window as any).ethereum.request({ method: 'eth_requestAccounts' });
        const web3Provider = new ethers.BrowserProvider((window as any).ethereum);
        setProvider(web3Provider); // providerは現時点で未使用
        const web3Signer = await web3Provider.getSigner();
        setSigner(web3Signer);
        const chatGptContract = new ethers.Contract(contractAddress, contractABI, web3Signer);
        setContract(chatGptContract);
      } else {
        console.error('MetaMask is not installed');
      }
    };

    initWeb3();
  }, []);

  const sendMessage = async () => {
    if (contract && message) {
      try {
        const tx = await contract.startChat(message);
        await tx.wait();
        setChatHistory([...chatHistory, `User: ${message}`]);
        setMessage('');
      } catch (error) {
        console.error('Error sending message:', error);
      }
    }
  };

  return (
    <div className="App">
      <main>
        <div>
          <h2>Chat with Smart Contract</h2>
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Type your message"
          />
          <button onClick={sendMessage}>Send</button>
        </div>
        <div>
          <h3>Chat History</h3>
          <ul>
            {chatHistory.map((msg, index) => (
              <li key={index}>{msg}</li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
}

export default App;
