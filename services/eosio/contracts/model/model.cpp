#include <eosio/eosio.hpp>
#include <vector>

using namespace eosio;

class [[eosio::contract]] model : public contract {
  
  public:

    struct modelparam {
      name owner; // ex useraaaaaaaa
      uint64_t turn; // which turn
      std::string hash; // model hash in ipfs
      EOSLIB_SERIALIZE(modelparam, (owner)(turn)(hash))
    };

    struct epoch {
      uint64_t id; // which epoch
      uint64_t turn; // which turn
			std::string time;
			uint64_t accuracy;
      EOSLIB_SERIALIZE(epoch, (id)(turn)(time)(accuracy))
    };

    model(name receiver, name code,  datastream<const char*> ds): contract(receiver, code, ds) {}

    // register model
    // store model hash, num into table
    [[eosio::action]]
    void enroll(name owner, uint64_t num, uint64_t accuracy, std::string hash){
      require_auth(owner);
      tasks_table tasks(_self, _self.value);
      auto id = tasks.available_primary_key();
      
      tasks.emplace(owner, [&](auto& new_task) {
        new_task.id  = id;
        new_task.owner = owner;
        new_task.num  = num;
        new_task.accuracy  = accuracy;
        new_task.upload_num = 0;
        new_task.turn  = 0;
        new_task.hash = hash;
        new_task.status = "WAITING";
      });

      eosio::print("task#", id, " registered");
    }

    // model owner update new model which uploaded to IPFS
    // store IPFS hash to blockchain
    // update this task's hash
    [[eosio::action]]
    void update(uint64_t id, std::string hash){
      
      tasks_table tasks(_self, _self.value);
      auto task_lookup = tasks.find(id);
      eosio::check(task_lookup != tasks.end(), "Task does not exist");
      name owner = task_lookup->owner;
      require_auth(owner);
      tasks.modify(task_lookup, owner,[&](auto& row) {
        row.upload_num = 0;
        row.turn = task_lookup->turn + 1;
        row.hash = hash;
        row.status = "WAITING";
      });

      eosio::print("task#", id, " registered");
      eosio::print("turn#", task_lookup->turn, " starts");
    }

    // trainer upload model hash
    // store hash into table
    [[eosio::action]]
    void upload(name uploader, uint64_t id, std::string hash){

      require_auth(uploader);
      tasks_table tasks(_self, _self.value);
      auto task_lookup = tasks.find(id);
      eosio::check(task_lookup != tasks.end(), "Task does not exist");
      
      if(task_lookup->status == "WAITING"){
        if(task_lookup->num > task_lookup->upload_num){
          modelparam mp = {uploader, task_lookup->turn, hash};
          tasks.modify(task_lookup, uploader,[&](auto& row) {
            row.upload_num = task_lookup->upload_num + 1;
            row.modelparams.push_back(mp);
          });

          eosio::print("model params in IPFS: ", hash, " uploaded by ", uploader);
        } else if(task_lookup->num < task_lookup->upload_num){
          eosio::print("this turn upload numbers exceeded limit number!!");
        } else{
          eosio::print("this turn's model can start to aggregate~");
          tasks.modify(task_lookup, uploader,[&](auto& row) {
            row.status = "AGGREGATING";
          });
        }
      } else if(task_lookup->status == "AGGREGATING") { // status = "AGGREGATING"
        eosio::print("this turn's model is aggregating!!plz wait for next turn~");
      } else { // status = "CONVERGENT"
        eosio::print("this task is finished~");
      }
      
    }

    // store training accuracy into table
    [[eosio::action]]
    void record(uint64_t id, uint64_t epochid, uint64_t turn, std::string time, uint64_t accuracy){
      
      tasks_table tasks(_self, _self.value);
      auto task_lookup = tasks.find(id);
      eosio::check(task_lookup != tasks.end(), "Task does not exist");
      name owner = task_lookup->owner;
      require_auth(owner);
      epoch e = {epochid, turn, time, accuracy};
      tasks.modify(task_lookup, owner, [&](auto& row) {
        row.epochs.push_back(e);
      });

      eosio::print("This turn is ",turn ,".Record in", time, " epochs #", epochid, "accuracy: ", accuracy);
    }
    
    // model owner call this to let others know the model is convergent and this task is finished
    [[eosio::action]]
    void convergent(uint64_t id){
      
      tasks_table tasks(_self, _self.value);
      auto task_lookup = tasks.find(id);
      eosio::check(task_lookup != tasks.end(), "Task does not exist");
      name owner = task_lookup->owner;
      require_auth(owner);

      tasks.modify(task_lookup, owner, [&](auto& row) {
        row.status = "CONVERGENT";
      });

      eosio::print("This task is Finished!!");
    }

    // remove this task from table
    [[eosio::action]]
    void remove(uint64_t id){

      tasks_table tasks(_self, _self.value);
      auto task_lookup = tasks.find(id);
      eosio::check(task_lookup != tasks.end(), "Task does not exist");
      name owner = task_lookup->owner;
      require_auth(owner);
      tasks.erase(task_lookup);

      eosio::print("task#", id, " destroyed");
    }

  private:

    struct [[eosio::table]] task {
      uint64_t id; // task id
      name owner;
      uint64_t num; // aggregate condition
      uint64_t accuracy; // convergent condition
      uint64_t upload_num; // when upload_num>=num, will aggregate params
      uint64_t turn; // which turn now
      std::string hash; // ipfs hash
      std::string status; // task status "WAITING" "AGGREGATING" "CONVERGENT"
      std::vector<modelparam> modelparams;
      std::vector<epoch> epochs;
      auto primary_key() const { return id; }
      EOSLIB_SERIALIZE(task, (id)(owner)(num)(turn)(upload_num)(hash)(status)(modelparams)(epochs))
    };

    using tasks_table = eosio::multi_index<"tasks"_n, task>;

};