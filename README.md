# FastClean
## 1.What is it ?
A tool based on Swift Package Manager, it can help iOS developers monitor the memory usage in the develop directory. In addition, it also supports deleting derivedData cache files, and other features are on the way.

## 2.How to use it ?

1. Download the project
    ```swift
   git clone https://github.com/Tonsjkjkas/FastClean.git
   ```

3. Enter the main project directory you downloaded
  ```swift
   cd ~/Downloads/FastClean-master
   ```
<img width="449" alt="截屏2025-04-11 18 07 17" src="https://github.com/user-attachments/assets/ee274dbd-b1f9-415e-9f64-35777e3866ff" />


4. Run this plugin in your bash

   ```swift
   swift build -c release	
   cp -f .build/release/fast-clean /usr/local/bin/fast-clean
   ```

5. Go to start
     ```swift
   fast-clean cache list
   ```
## 3.Examples
### 1.Show all directories
   ```swift
   fast-clean cache list
   fast-clean cache list --cache-folder all //equal to :fast-clean cache list
   //show the all directory size of cache
   ```

<img width="718" alt="截屏2025-04-11 01 04 29" src="https://github.com/user-attachments/assets/dc6a091f-13c3-401f-b604-bc9752e70482" />

### 2. Display the size of a single directory
   ```swift
   fast-clean cache list --cache-folder derivedData 
   //show the all directory size of cache
   ```
<img width="595" alt="截屏2025-04-11 01 18 39" src="https://github.com/user-attachments/assets/7cb1b3e1-9848-4501-a8e3-7ad5a91dbeb3" />

### 3. Delete a single directory
  ```swift
   fast-clean cache list --cache-folder derivedData 
   //show the all directory size of cache
   ```
<img width="543" alt="截屏2025-04-11 01 19 58" src="https://github.com/user-attachments/assets/752a8fcc-8004-49ea-8d27-8dc404545642" />

### 4. Force delete a directory
  ```swift
    fast-clean cache delete --cache-folder derivedData --force
   //show the all directory size of cache
   ```

<img width="671" alt="截屏2025-04-11 01 25 18" src="https://github.com/user-attachments/assets/b395e06f-2e16-4fa6-85da-667dcea22146" />

### 5. Force delete all directories
I don't recommend you to do this, you should be selective about the directory you want to delete. But if you really want to do this, you should execute the following command:

  ```swift
   fast-clean cache delete  --cache-folder all --force
   ```
## 4.Required environment
| Env      | Version |
| ----------- | ----------- |
| Mac os      | >= Mac os 12.7.6       |
| Xcode   | >= Xcode 13        |




