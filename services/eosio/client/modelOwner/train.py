import sys
import torch
import torchvision
import torchvision.transforms as transforms
import torch.optim as optim
import torch.nn as nn
import model as m
import json

BATCH_SIZE = 32
# number of subprocesses to use for data loading
NUM_WORKERS = 0
# learning rate
LR = 0.001
EPOCHS = 20

def testFL(test_loader, model):
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
  model.to(device)
  return test(model, device, test_loader)

def trainFL(train_loader, test_loader, model):
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
  model.to(device)
  train(model, device, train_loader)
  return test(model, device, test_loader)

def train(model, device, train_loader):
  loss_func = nn.CrossEntropyLoss()
  optimizer = optim.Adam(model.parameters(), lr=LR)
  # optimizer = optim.SGD(model.parameters(), lr=LR)
  for epoch in range(EPOCHS):
    flag = 0
    for images, labels in train_loader:
      images = images.reshape(-1, 28 * 28).to(device)
      labels = labels.to(device)
      output = model(images)

      loss = loss_func(output, labels)
      optimizer.zero_grad()
      loss.backward()
      optimizer.step()
      
      # if (flag + 1) % 10 == 0:
          # print('Epoch [{}/{}], Loss: {:.4f}'.format(epoch + 1, epoches, loss.item()))
      flag += 1

def test(convergnet, model, device, test_loader):
  # convergnet flag
  flag = False
  # calculate accuracy
  correct = 0
  total = 0
  for images, labels in test_loader:
    images = images.reshape(-1, 28 * 28).to(device)
    labels = labels.to(device)
    output = model(images)
    values, predicte = torch.max(output, 1)
    total += labels.size(0)
    # predicte == labels
    correct += (predicte == labels).sum().item()
  accuracy = 100 * correct / total
  print("The accuracy of total {} images: {}%".format(total, accuracy))

  if(accuracy >= convergnet):
    flag = True

  return flag

def combine_params(hashs):
  # init
  hash = hashs[0]
  param = torch.load(hash)
  total_param_fc1 = torch.zeros(param[0][1].shape)
  total_param_fc2 = torch.zeros(param[2][1].shape)

  # combine param
  for i in hashs:
    param = torch.load(i)
    total_param_fc1+=param[0][1].data
    total_param_fc2+=param[2][1].data

  # average combine param
  total_param_fc1/=num
  total_param_fc2/=num

  return total_param_fc1, total_param_fc2

def write_convergent_result_json(convergent):
  data = {'convergent':convergent}
  with open('convergent.txt', 'w') as outfile:
    json.dump(data, outfile)

# sys.argv[1] is convergent accuracy
# sys.argv[2~]
if __name__ == "__main__" :
  num = len(sys.argv)
  print('Number of arguments:', num, 'arguments.')
  print('Argument List:', str(sys.argv))

  # train_set = torchvision.datasets.MNIST(root="./data",train=True,transform=transforms.ToTensor(),download=True)
  test_set = torchvision.datasets.MNIST(root="./data",train=False,transform=transforms.ToTensor(),download=True)
  # 60000/3
  # train_ds_size = int(len(train_set)/3)
  # model_owner_ds, t_model_owner_ds, t2_model_owner_ds = torch.utils.data.random_split(train_set, [train_ds_size, train_ds_size, train_ds_size])

  # model_owner_train_loader = torch.utils.data.DataLoader(model_owner_ds, batch_size=BATCH_SIZE, num_workers=NUM_WORKERS,shuffle=True)

  # 10000
  test_loader = torch.utils.data.DataLoader(test_set, batch_size=BATCH_SIZE, num_workers=NUM_WORKERS,shuffle=True)

  hashs = []
  for i in range(2, num):
    hash = sys.argv[i]
    hashs.append(hash)
  
  total_param_fc1, total_param_fc2 = combine_params(hashs)
  model = m.FLNeuralNet(total_param_fc1, total_param_fc2)

  # save new model
  torch.save(model.state_dict(),'model.pth')

  # model owner test, get convergent flag
  convergent = sys.argv[1]
  convergent = float(convergent)
  flag=testFL(convergent ,test_loader, model)
  write_convergent_result_json(flag)

  sys.exit(0)
