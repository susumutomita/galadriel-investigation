const path = require('path');
const fs = require('fs');
const solc = require('solc');

const contractPath = path.resolve(__dirname, 'src', 'ChatGpt.sol');
const source = fs.readFileSync(contractPath, 'utf8');

const findImports = (importPath) => {
  try {
    const fullPath = path.resolve(__dirname, 'src', importPath);
    const content = fs.readFileSync(fullPath, 'utf8');
    return { contents: content };
  } catch (error) {
    return { error: 'File not found' };
  }
};

const input = {
  language: 'Solidity',
  sources: {
    'ChatGpt.sol': {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['abi', 'evm.bytecode'],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input), { import: findImports }));

// コンパイル結果の確認
console.log(output);

if (!output.contracts || !output.contracts['ChatGpt.sol'] || !output.contracts['ChatGpt.sol']['ChatGpt']) {
  throw new Error('Compilation failed or contract not found in output');
}

const abi = output.contracts['ChatGpt.sol']['ChatGpt'].abi;

// 出力パスの変更
const outputPath = path.resolve(__dirname, 'gradrial-web', 'src', 'abi', 'ChatGptABI.json');
fs.writeFileSync(outputPath, JSON.stringify(abi, null, 2));
console.log(`ABI has been saved to ${outputPath}`);
