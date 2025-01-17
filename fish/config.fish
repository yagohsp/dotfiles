if status is-interactive
    # Commands to run in interactive sessions can go here
end

# set -g DOTNET_ROOT $HOME/.dotnet
# set -g PATH $PATH $HOME/.dotnet
# set -g PATH $PATH $HOME/.dotnet/tools

set -g PATH ~/.local/share/nvim/mason/bin $PATH

# # Function to remove duplicates from PATH
# function remove_path_duplicates
#     set -l unique_paths
#     for dir in $PATH
#         if not contains $dir $unique_paths
#             set -a unique_paths $dir
#         end
#     end
#     set -x PATH $unique_paths
# end

# # Call the function to remove duplicates
# remove_path_duplicates
