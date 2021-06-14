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

class FLNeuralNet(nn.Module):
  def __init__(self, com_para_fc1,com_para_fc2):
    super(FLNeuralNet, self).__init__()
    self.fc1 = nn.Linear(784, 12)
    self.fc2 = nn.Linear(12, 10)
    self.fc1.weight=Parameter(com_para_fc1)
    self.fc2.weight=Parameter(com_para_fc2)
    nn.init.constant_(self.fc1.bias, val=0)
    nn.init.constant_(self.fc2.bias, val=0)
    self.relu = nn.ReLU()

  def forward(self, x):
    x = self.fc1(x)
    x = self.relu(x)
    y = self.fc2(x)
    return y

def save_model():
  model = NeuralNet()
  torch.save(model.state_dict(), 'model.pth')
  summary(model, (28*28,))

def upload_model_to_ipfs():
  client = ipfshttpclient.connect('/dns/ipfs/tcp/5001/http')
  hash = client.add('model.pth')['Hash']
  print(hash)
  # return hash

def load_model_param_from_ipfs(hash):
  client = ipfshttpclient.connect('/dns/ipfs/tcp/5001/http')
  client.get(hash)