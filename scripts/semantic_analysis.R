library(rstudioapi)
library(stringr)
library(dplyr)
library(purrr)
library(ggplot2)
library(igraph)
library(reshape2)
library(tidyr)


##The following code is for setting the path
file_script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
parent_dir <- file.path(current_script_dir, "..")
results_path <- file.path(parent_dir, "results")
load(paste0(results_path, "/categorized.Rdata"))


##The following code is for department tagging 
distribution_sender <- categorized_data %>%
  group_by(sender, sender_department) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count)) 
plot_sender <- ggplot(distribution_sender, aes(x = reorder(sender, -count), y = count, fill = sender_department)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Distribution of sender's Departments",
       x = "sender",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_discrete(name = "sender Department")+theme(plot.background = element_rect(fill = "white", color = NA))
# save plot
#ggsave(filename = "sender_distribution_plot.png", plot = plot_sender, width = 25, height = 6, dpi = 350)




distribution_receiver <- categorized_data %>%
  group_by(receiver, receiver_department) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count)) 
plot_receiver <- ggplot(distribution_receiver, aes(x = reorder(receiver, -count), y = count, fill = receiver_department)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Distribution of receiver's Departments",
       x = "receiver",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_discrete(name = "receiver Department")+theme(plot.background = element_rect(fill = "white", color = NA))
# save plot
# ggsave(filename = "receiver_distribution_plot.png", plot = plot_receiver, width = 25, height = 6, dpi = 350)

sender_highest_percent <- categorized_data %>%
  group_by(sender, sender_department) %>% # Group by sender and department
  summarise(count = n(), .groups = "drop") %>% # Count occurrences
  group_by(sender) %>% # Group by sender again
  mutate(percent = count / sum(count) * 100) %>% # Calculate percentage
  slice_max(percent, n = 1, with_ties = FALSE) %>% # Select the department with the highest percentage
  select(sender, sender_department, percent) # Keep relevant columns

# View sender result
# print(sender_highest_percent)

# Calculate highest percentage department for each receiver
receiver_highest_percent <- categorized_data %>%
  group_by(receiver, receiver_department) %>% # Group by receiver and department
  summarise(count = n(), .groups = "drop") %>% # Count occurrences
  group_by(receiver) %>% # Group by receiver again
  mutate(percent = count / sum(count) * 100) %>% # Calculate percentage
  slice_max(percent, n = 1, with_ties = FALSE) %>% # Select the department with the highest percentage
  select(receiver, receiver_department, percent) # Keep relevant columns

receiver_highest_percent$department_code <- as.numeric(as.factor(receiver_highest_percent$receiver_department))

persent_dom_plot_receiver = ggplot(receiver_highest_percent, aes(x = receiver, y = percent, fill = receiver_department)) +
  geom_bar(stat = "identity", position = "stack", width = 0.6) +
  scale_fill_manual(values = c("Operations" = "skyblue", "Trading" = "orange", "Technology" = "green","Legal"="red", "Finance"="yellow","Human"="purple")) +
  labs(
    title = "Dominant Departments",
    x = "Receiver",
    y = "Percentage",
    fill = "Department"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+theme(plot.background = element_rect(fill = "white", color = NA))
# save plot
# ggsave(filename = "persent_dom_plot_receiver.png", plot = persent_dom_plot_receiver, width = 25, height = 6, dpi = 350)


sender_highest_percent$department_code <- as.numeric(as.factor(sender_highest_percent$sender_department))

persent_dom_plot_sender = ggplot(sender_highest_percent, aes(x = sender, y = percent, fill = sender_department)) +
  geom_bar(stat = "identity", position = "stack", width = 0.6) +
  scale_fill_manual(values = c("Operations" = "skyblue", "Trading" = "orange", "Technology" = "green","Legal"="red", "Finance"="yellow","Human"="purple")) +
  labs(
    title = "Dominant Departments",
    x = "Sender",
    y = "Percentage",
    fill = "Department"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+theme(plot.background = element_rect(fill = "white", color = NA))
# save plot
# ggsave(filename = "persent_dom_plot_sender.png", plot = persent_dom_plot_sender, width = 25, height = 6, dpi = 350)




# Merge the two data frames
combined_data <- full_join(
  sender_highest_percent %>% rename(name = sender, sender_percent = percent, sender_department = sender_department),
  receiver_highest_percent %>% rename(name = receiver, receiver_percent = percent, receiver_department = receiver_department),
  by = "name"
)

# Compare and label
labeled_data <- combined_data %>%
  mutate(
    chosen_percent = case_when(
      # If both percentages are present, take the higher one
      !is.na(sender_percent) & !is.na(receiver_percent) ~ pmax(sender_percent, receiver_percent),
      # If only sender_percent is present
      !is.na(sender_percent) & is.na(receiver_percent) ~ sender_percent,
      # If only receiver_percent is present
      is.na(sender_percent) & !is.na(receiver_percent) ~ receiver_percent,
      # Default case (should not happen if data is clean)
      TRUE ~ NA_real_
    ),
    chosen_department = case_when(
      # If sender_percent is chosen
      chosen_percent == sender_percent ~ sender_department,
      # If receiver_percent is chosen
      chosen_percent == receiver_percent ~ receiver_department,
      # Default case (should not happen if data is clean)
      TRUE ~ NA_character_
    )
  )

# Select relevant columns for final output
final_data <- labeled_data %>%
  select(name, chosen_department, chosen_percent)

relabelled_data <- categorized_data %>%
  left_join(final_data %>%
              rename(sender = name,
                     sender_chosen_department = chosen_department,
                     sender_chosen_percent = chosen_percent),
            by = "sender") %>%
  left_join(final_data %>%
              rename(receiver = name,
                     receiver_chosen_department = chosen_department,
                     receiver_chosen_percent = chosen_percent),
            by = "receiver") %>%
  mutate(sender_department = coalesce(sender_chosen_department, sender_department),
         receiver_department = coalesce(receiver_chosen_department, receiver_department)) %>%
  select(-sender_chosen_department, -sender_chosen_percent,
         -receiver_chosen_department, -receiver_chosen_percent)


# Compute communication frequencies between departments
communication_matrix <- relabelled_data %>%
  group_by(sender_department, receiver_department) %>%
  summarise(frequency = n(), .groups = "drop") %>%
  pivot_wider(names_from = receiver_department,
              values_from = frequency,
              values_fill = list(frequency = 0))

# Convert to matrix for heatmap
communication_matrix_for_heatmap <- as.matrix(
  communication_matrix %>% select(-sender_department)
)
rownames(communication_matrix_for_heatmap) <- communication_matrix$sender_department



melted_matrix <- melt(communication_matrix_for_heatmap)
colnames(melted_matrix) <- c("Sender_Department", "Receiver_Department", "Frequency")


# Categorize frequencies into bins
melted_matrix$Frequency_Binned <- cut(
  melted_matrix$Frequency,
  breaks = c(-Inf, 0, 1, 10, Inf),  # Define bins (0 explicitly as a separate bin)
  labels = c("Zero", "Low", "Medium", "High")
)

Inter_depart_commu_heapmap = ggplot(melted_matrix, aes(x = Sender_Department, y = Receiver_Department, fill = Frequency_Binned)) +
  geom_tile() +
  scale_fill_manual(
    values = c("Zero" = "grey90", "Low" = "lightblue", "Medium" = "blue", "High" = "darkblue")
  ) +
  labs(
    title = "Inter-Department Communication Heatmap ",
    x = "Sender Department",
    y = "Receiver Department",
    fill = "Frequency"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+theme(plot.background = element_rect(fill = "white", color = NA))
#save plot
#ggsave(filename = "Inter_depart_commu_heap_map.png", plot = Inter_depart_commu_heapmap, width = 8, height = 6, dpi = 350)


# Analyze directional communication flows
directional_patterns <- relabelled_data %>%
  group_by(sender_department, receiver_department) %>%
  summarise(total_communications = n(), .groups = "drop") %>%
  arrange(desc(total_communications))

#print(directional_patterns)







# Calculate tone distribution by sender department
tone_distribution <- categorized_data %>%
  group_by(sender_department, tone) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(sender_department) %>%  # Group by sender department
  mutate(percentage = count / sum(count) * 100)  # Calculate percentage within each department

# Plot tone distribution by department
tone_distribution_plot <- ggplot(tone_distribution, aes(x = sender_department, y = percentage, fill = tone)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +  # Add border for better contrast
  labs(
    title = "Tone Distribution by Sender Department",
    x = "Sender Department",
    y = "Percentage",
    fill = "Tone"
  ) +
  scale_fill_brewer(palette = "Set2") +  # Use a nice color palette
  theme_minimal(base_size = 14) +  # Adjust base font size
  theme(
    panel.background = element_rect(fill = "white", color = "black"),  # White background
    panel.grid.major = element_line(color = "grey80"),                # Soft grid lines
    panel.grid.minor = element_blank(),                               # Remove minor grid lines
    axis.text.x = element_text(angle = 45, hjust = 1),                # Rotate x-axis labels
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold")  # Center and style title
  )

# Save the plot 
# ggsave(
#   filename = "tone_distribution_by_sender_department.png",  # File name
#   plot = tone_distribution_plot,                           # Plot to save
#   device = "png",                                          # File format
#   dpi = 350,                                              # High DPI for quality
#   width = 10,                                             # Width in inches
#   height = 6,                                             # Height in inches
#   bg = "white"                                            # Ensure white background
# )








##The following code is for sentiment Analysis 

# Map tones to sentiment scores
tone_to_sentiment <- c(
  "Supportive" = 1,        # Strongly Positive
  "Informative" = -0.5,     # Mildly Negative
  "Imperative" = -1,     # Stronly Negative
  "Deferential" = 0.5      # Mildly Positive
)

# Add sentiment scores to categorized_data
categorized_data <- categorized_data %>%
  mutate(sentiment_score = tone_to_sentiment[tone])

# Calculate average sentiment by sender and receiver departments
sentiment_by_department <- categorized_data %>%
  group_by(sender_department, receiver_department) %>%
  summarise(
    avg_sentiment = mean(sentiment_score, na.rm = TRUE),
    .groups = "drop"
  )

# Heatmap for Inter-department Sentiment

heatmap_data <- sentiment_by_department %>%
  pivot_wider(
    names_from = receiver_department,
    values_from = avg_sentiment,
    values_fill = list(avg_sentiment = 0)
  )

# Convert to matrix for visualization
heatmap_matrix <- as.matrix(heatmap_data %>% select(-sender_department))
rownames(heatmap_matrix) <- heatmap_data$sender_department

# Melt the matrix for ggplot
melted_heatmap <- melt(heatmap_matrix)
colnames(melted_heatmap) <- c("Sender_Department", "Receiver_Department", "Avg_Sentiment")

# Plot heatmap
sentiment_heatmap <- ggplot(melted_heatmap, aes(x = Sender_Department, y = Receiver_Department, fill = Avg_Sentiment)) +
  geom_tile() +
  scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0) +
  labs(
    title = "Average Sentiment Between Departments",
    x = "Sender Department",
    y = "Receiver Department",
    fill = "Avg Sentiment"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),  
    panel.background = element_rect(fill = "white")     
  )

# Save the plot 
# ggsave(
#   filename = "average_sentiment_heatmap.png",  
#   plot = sentiment_heatmap,                  
#   device = "png",                            
#   dpi = 350,                                 
#   width = 8,                                
#   height = 6,                                
#   bg = "white"                              
# )
