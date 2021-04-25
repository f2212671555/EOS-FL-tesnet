#include <eosio/eosio.hpp>

using namespace eosio;

class [[eosio::contract]] todo : public contract {
  public:

    todo(name receiver, name code,  datastream<const char*> ds): contract(receiver, code, ds) {}

    [[eosio::action]]
    void create(name owner, std::string task){
      require_auth(owner);

      tasks_table tasks(_self, _self.value);
      auto id = tasks.available_primary_key();

      tasks.emplace(owner, [&](auto& new_task) {
        new_task.id  = id;
        new_task.task = task;
        new_task.owner = owner;
        new_task.status = "TODO";
      });

      eosio::print("task#", id, " created");
    }

    [[eosio::action]]
    void update(uint64_t id, std::string new_status){
      tasks_table tasks(_self, _self.value);

      auto iterator = tasks.find(id);

      eosio::check(iterator != tasks.end(), "Todo does not exist");
      
      name owner = task_lookup->owner;
      require_auth(owner);

      tasks.modify(task_lookup, eosio::same_payer, [&](auto& row) {
        row.status = new_status;
      });

      eosio::print("todo#", id, " marked as complete");
    }
    
    [[eosio::action]]
    void remove(uint64_t id){
      tasks_table tasks(_self, _self.value);

      auto todo_lookup = tasks.find(id);
      tasks.erase(todo_lookup);

      eosio::print("todo#", id, " destroyed");
    }

  private:
    struct [[eosio::table]] task {
      uint64_t id; // task id
      name owner;
      std::string task;
      std::string status;
      auto primary_key() const { return id; }
    };

    using tasks_table = eosio::multi_index<"tasks"_n, task>;

};