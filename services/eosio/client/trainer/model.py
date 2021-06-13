import torch
import torch.nn as nn
from torch.nn import Parameter
from torchsummary import summary
import ipfshttpclient # pip3 install ipfshttpclient==0.8.0a2

class NeuralNet(nn.Module):
  def __init__(self):
    super(NeuralNet, self).__init__()
    self.fc1 = nn.Linear(784, 12)
    self.fc2 = nn.Linear(12, 10)
    nn.init.normal_(self.fc1.weight)
    nn.init.normal_(self.fc2.weight)
    nn.init.constant_(self.fc1.bias, val=0)  # init bias = 0
    nn.init.constant_(self.fc2.bias, val=0)
    self.relu = nn.ReLU()

  def forward(self, x):
    x = self.fc1(x)
    x = self.relu(x)
    y = self.fc2(x)
    return y

def load_model(hash):
  client = ipfshttpclient.connect('/dns/ipfs/tcp/5001/http')
  client.get(hash)
  model = NeuralNet()
  model.load_state_dict(torch.load(hash))
  model.eval()
  summary(model, (28*28,))
  return model

def upload_params_to_ipfs():
  client = ipfshttpclient.connect('/dns/ipfs/tcp/5001/http')
  hash = client.add('paramsA.pth')['Hash']
  print(hash)