import sys
import torch
import torchvision
import torchvision.transforms as transforms
import torch.optim as optim
import torch.nn as nn
import model as m

BATCH_SIZE = 32
# number of subprocesses to use for data loading
NUM_WORKERS = 0
# learning rate
LR = 0.001
EPOCHS = 20

def trainNormal(train_loader, test_loader, model):
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

def test(model, device, test_loader):
  params = list(model.named_parameters())

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
  print("The accuracy of total {} images: {}%".format(total, 100 * correct / total))
  return params

if __name__ == "__main__" :
  train_set = torchvision.datasets.MNIST(root="../data",train=True,transform=transforms.ToTensor(),download=True)
  test_set = torchvision.datasets.MNIST(root="../data",train=False,transform=transforms.ToTensor(),download=True)
  # 60000/3
  train_ds_size = int(len(train_set)/3)
  alice_train_ds, bob_train_ds, carol_train_ds = torch.utils.data.random_split(train_set, [train_ds_size, train_ds_size, train_ds_size])

  # alice_train_loader = torch.utils.data.DataLoader(alice_train_ds, batch_size=BATCH_SIZE, num_workers=NUM_WORKERS,shuffle=True)
  bob_train_loader = torch.utils.data.DataLoader(bob_train_ds, batch_size=BATCH_SIZE, num_workers=NUM_WORKERS,shuffle=True)
  # carol_train_loader = torch.utils.data.DataLoader(carol_train_ds, batch_size=BATCH_SIZE, num_workers=NUM_WORKERS,shuffle=True)

  # 10000
  test_loader = torch.utils.data.DataLoader(test_set, batch_size=BATCH_SIZE, num_workers=NUM_WORKERS,shuffle=True)
  model = m.load_model(sys.argv[1])
  
  # local train
  # para_A=trainNormal(alice_train_loader, test_loader, model)
  para_B=trainNormal(bob_train_loader,test_loader)
  # para_C=trainNormal(carol_train_loader,test_loader)
  # print(para_A)
  torch.save(para_B,'params.pth')
