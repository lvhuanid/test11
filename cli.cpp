#include <nlohmann/json.hpp>



cli_bufprint(cli, "aaParams: %s\n", params.dump().c_str());

// source tree
void traverse_board_config(struct cli_def *cli, const std::string &board_type, const std::string &slot,
                           const std::string &command, int indent = 0,
                           std::unordered_set<std::string> *visited = nullptr) {
    static thread_local std::unordered_set<std::string> local_visited;