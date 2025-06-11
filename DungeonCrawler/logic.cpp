#include <iostream>
#include <fstream>
#include <string>
#include "logic.h"

using namespace std;

/**
 * TODO: Student implement this function
 * Load representation of the dungeon level from file into the 2D map.
 * Calls createMap to allocate the 2D array.
 * @param   fileName    File name of dungeon level.
 * @param   maxRow      Number of rows in the dungeon table (aka height).
 * @param   maxCol      Number of columns in the dungeon table (aka width).
 * @param   player      Player object by reference to set starting position.
 * @return  pointer to 2D dynamic array representation of dungeon map with player's location., or nullptr if loading fails for any reason
 * @updates  maxRow, maxCol, player
 */
char** loadLevel(const string& fileName, int& maxRow, int& maxCol, Player& player) {
    ifstream ifs(fileName);

    //file fail to open
    if(!ifs.is_open())
        return nullptr;

    //Line 1: Map Dimensions
    //Row
    ifs >> maxRow; 
    if(ifs.fail())
        return nullptr;

    if(maxRow < 1)
        return nullptr;

    //Col
    ifs >> maxCol;
    if(ifs.fail())
        return nullptr;
    
    if(maxCol < 1)
        return nullptr;
    
    //Tile max check
    if(maxRow > INT32_MAX / maxCol)
        return nullptr;
    
    //Line 2: Player Starting Location
    //Row
    ifs >> player.row;
    if(ifs.fail())
        return nullptr;

    if(player.row < 0 || player.row >= maxRow)
        return nullptr;

    //Col
    ifs >> player.col;
    if(ifs.fail())
        return nullptr;
    if(player.col < 0 || player.col >= maxCol)
        return nullptr;
    
    //Line 3+ tile info
    //Create map
    char** map = createMap(maxRow, maxCol);
    char tile ='\0'; 
    bool escape = false;
    
    //Check tiles
    int tile_count = 0;
    int tile_total = maxRow * maxCol;

    //Populate map
    for(int i = 0; i < maxRow; i++){
        for(int j = 0; j < maxCol; j++){
            // get tile
            ifs >> tile;
            // out of tiles
            if(ifs.eof()){
                if(tile_count < tile_total){
                    deleteMap(map, maxRow);
                    return nullptr;
                }
            }

            tile_count++;
            
            //assign char to tile
            switch(tile){
                case TILE_DOOR:
                    map[i][j] = tile;
                    escape = true;
                    break;
                
                case TILE_EXIT:
                    map[i][j] = tile;
                    escape = true;
                    break;
                
                case TILE_OPEN:
                    map[i][j] = tile;
                    break;
                
                case TILE_PLAYER:
                    map[i][j] = tile;
                    break;
                
                case TILE_TREASURE:
                    map[i][j] = tile;
                    break;
                
                case TILE_AMULET:
                    map[i][j] = tile;
                    break;
                
                case TILE_MONSTER:
                    map[i][j] = tile;
                    break;
                
                case TILE_PILLAR:
                    map[i][j] = tile;
                    break;
                
                default: 
                    deleteMap(map, maxRow);
                    return nullptr;
            }       
        }  
    } 

    //extra tiles
    if(ifs.peek() != EOF){
        deleteMap(map, maxRow);
        return nullptr;
    }

    //no escape
    if(!escape){
        deleteMap(map, maxRow);
        return nullptr;
    }

    //player location in map
    map[player.row][player.col] = TILE_PLAYER;

    return map;
}

/**
 * TODO: Student implement this function
 * Translate the character direction input by the user into row or column change.
 * That is, updates the nextRow or nextCol according to the player's movement direction.
 * @param   input       Character input by the user which translates to a direction.
 * @param   nextRow     Player's next row on the dungeon map (up/down).
 * @param   nextCol     Player's next column on dungeon map (left/right).
 * @updates  nextRow, nextCol
 */
void getDirection(char input, int& nextRow, int& nextCol) {
    //input cases
    switch(tolower(input)){
        case MOVE_UP:
            nextRow--;
            break;
        case MOVE_DOWN:
            nextRow++;
            break;
        case MOVE_LEFT:
            nextCol--;
            break;
        case MOVE_RIGHT:
            nextCol++;
            break;
        default:
            break;
    }
}

/**
 * TODO: [suggested] Student implement this function
 * Allocate the 2D map array.
 * Initialize each cell to TILE_OPEN.
 * @param   maxRow      Number of rows in the dungeon table (aka height).
 * @param   maxCol      Number of columns in the dungeon table (aka width).
 * @return  2D map array for the dungeon level, holds char type.
 */
char** createMap(int maxRow, int maxCol) {
    //check map dimensions
    if(maxRow < 0 || maxCol < 0 || maxRow > 999999 || maxCol > 999999)
        return nullptr;
    
    //Initiliaze map
    //2D array
    char** map = new char* [maxRow];
    //Populate map
    for(int i = 0; i < maxRow; i++){
        //1D array
        map[i] = new char[maxCol];
        for(int j = 0; j < maxCol; j++){
            //tile info
            map[i][j] = TILE_OPEN;
        }
    }

    return map;
}

/**
 * TODO: Student implement this function
 * Deallocates the 2D map array.
 * @param   map         Dungeon map.
 * @param   maxRow      Number of rows in the dungeon table (aka height).
 * @return None
 * @update map, maxRow
 */
void deleteMap(char**& map, int& maxRow) {
   if(map){
    for(int i = 0; i < maxRow; i++){
        //Delete 1D
        delete[] map[i];
        }

    delete[] map;
   }    
    map = nullptr;
    maxRow = 0;
}

/**
 * TODO: Student implement this function
 * Resize the 2D map by doubling both dimensions.
 * Copy the current map contents to the right, diagonal down, and below.
 * Do not duplicate the player, and remember to avoid memory leaks!
 * You can use the STATUS constants defined in logic.h to help!
 * @param   map         Dungeon map.
 * @param   maxRow      Number of rows in the dungeon table (aka height), to be doubled.
 * @param   maxCol      Number of columns in the dungeon table (aka width), to be doubled.
 * @return  pointer to a dynamically-allocated 2D array (map) that has twice as many columns and rows in size.
 * @update maxRow, maxCol
 */
char** resizeMap(char** map, int& maxRow, int& maxCol) {
    //check map and dimensions
    if(map == nullptr || maxRow < 1 || maxRow > 999999/2 || maxCol < 1 || maxCol > 999999/2)
        return nullptr;
    
    //resize map
    int row = maxRow;
    int col = maxCol;

    //temp map double size
    char** temp = new char*[maxRow * 2];
    for(int i = 0; i < maxRow * 2; i++){
        temp[i] = new char[maxCol * 2];
    }

    //Populate temp map
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            temp[i][j] = map[i][j];

            if(map[i][j] == TILE_PLAYER)
                temp[i][j + col] = TILE_OPEN;
            else
                temp[i][j + col] = map[i][j];
            
            if(map[i][j] == TILE_PLAYER)
                temp[i + row][j + col] = TILE_OPEN;
            else
                temp[i + row][j + col] = map[i][j];
            
            if(map[i][j] == TILE_PLAYER)
                temp[i + row][j] = TILE_OPEN;
            else
                temp[i + row][j] = map[i][j];
        }
    }

    //deallocate map
    deleteMap(map, row);
    maxRow *= 2;
    maxCol *= 2;

    return temp;
}

/**
 * TODO: Student implement this function
 * Checks if the player can move in the specified direction and performs the move if so.
 * Cannot move out of bounds or onto TILE_PILLAR or TILE_MONSTER.
 * Cannot move onto TILE_EXIT without at least one treasure. 
 * If TILE_TREASURE, increment treasure by 1.
 * Remember to update the map tile that the player moves onto and return the appropriate status.
 * You can use the STATUS constants defined in logic.h to help!
 * @param   map         Dungeon map.
 * @param   maxRow      Number of rows in the dungeon table (aka height).
 * @param   maxCol      Number of columns in the dungeon table (aka width).
 * @param   player      Player object to by reference to see current location.
 * @param   nextRow     Player's next row on the dungeon map (up/down).
 * @param   nextCol     Player's next column on dungeon map (left/right).
 * @return  Player's movement status after updating player's position.
 * @update map contents, player
 */
int doPlayerMove(char** map, int maxRow, int maxCol, Player& player, int nextRow, int nextCol) {
    //moving out of map
    if(nextRow < 0 || nextRow >= maxRow || nextCol < 0 || nextCol >= maxCol)
        return STATUS_STAY;
    
    //check next tile case
    switch(map[nextRow][nextCol]){
        case TILE_MONSTER:
            return STATUS_STAY;

        case TILE_PILLAR:
            return STATUS_STAY;
        
        case TILE_AMULET:
            //move player
            map[player.row][player.col] = TILE_OPEN;
            player.row = nextRow;
            player.col = nextCol;
            map[player.row][player.col] = TILE_PLAYER;
            return STATUS_AMULET;

        case TILE_TREASURE:
            //move player
            map[player.row][player.col] = TILE_OPEN;
            player.row = nextRow;
            player.col = nextCol;
            map[player.row][player.col] = TILE_PLAYER;
            //add treasure
            player.treasure++;
            return STATUS_TREASURE;
        
        case TILE_DOOR:
            //move player
            map[player.row][player.col] = TILE_OPEN;
            player.row = nextRow;
            player.col = nextCol;
            map[player.row][player.col] = TILE_PLAYER;
            return STATUS_LEAVE;
        
        case TILE_EXIT:
            //escape with treasure
            if(player.treasure){
                //move player
                map[player.row][player.col] = TILE_OPEN;
                player.row = nextRow;
                player.col = nextCol;
                map[player.row][player.col] = TILE_PLAYER;
                return STATUS_ESCAPE;
            }
            //no treasure
            else{
                return STATUS_STAY;
            }   
        
        case TILE_OPEN:
            //move player
            map[player.row][player.col] = TILE_OPEN;
            player.row = nextRow;
            player.col = nextCol;
            map[player.row][player.col] = TILE_PLAYER;
            return STATUS_MOVE;
        
        default:
            return STATUS_STAY;
    }
}

/**
 * TODO: Student implement this function
 * Update monster locations:
 * We check up, down, left, right from the current player position.
 * If we see an obstacle, there is no line of sight in that direction, and the monster does not move.
 * If we see a monster before an obstacle, the monster moves one tile toward the player.
 * We should update the map as the monster moves.
 * At the end, we check if a monster has moved onto the player's tile.
 * @param   map         Dungeon map.
 * @param   maxRow      Number of rows in the dungeon table (aka height).
 * @param   maxCol      Number of columns in the dungeon table (aka width).
 * @param   player      Player object by reference for current location.
 * @return  Boolean value indicating player status: true if monster reaches the player, false if not.
 * @update map contents
 */
bool doMonsterAttack(char** map, int maxRow, int maxCol, const Player& player) {
    char tile;
    bool attack = false;
    //Check if monster above
    for(int i = player.row - 1; i >= 0; i--){
        tile = map[i][player.col];
        if(tile == TILE_PILLAR)
            break;
        else if(tile == TILE_MONSTER){
            map[i][player.col] = TILE_OPEN;
            map[i + 1][player.col] = TILE_MONSTER;
            if(i + 1 == player.row)
                attack = true;
        }
    }

    //Check if monster below
    for(int i = player.row + 1; i < maxRow; i++){
        tile = map[i][player.col];
        if(tile == TILE_PILLAR)
            break;
        else if(tile == TILE_MONSTER){
            map[i][player.col] = TILE_OPEN;
            map[i - 1][player.col] = TILE_MONSTER;
            if(i - 1 == player.row)
                attack = true;
        }
    }

    //Check if monster left
    for(int i = player.col - 1; i >= 0; i--){
        tile = map[player.row][i];
        if(tile == TILE_PILLAR)
            break;
        else if(tile == TILE_MONSTER){
            map[player.row][i] = TILE_OPEN;
            map[player.row][i + 1] = TILE_MONSTER;
            if(i + 1 == player.col)
                attack = true;
        }
    }

    //Check if monster right
    for(int i = player.col + 1; i < maxCol; i++){
        tile = map[player.row][i];
        if(tile == TILE_PILLAR)
            break;
        else if(tile == TILE_MONSTER){
            map[player.row][i] = TILE_OPEN;
            map[player.row][i - 1] = TILE_MONSTER;
            if(i - 1 == player.col)
                attack = true;
        }
    }

    return attack;
}
