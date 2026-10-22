; ============================================
; DUNGEON ADVENTURE AND SURVIVAL GAME
; Student project - NASM Assembly
; Runs in GitHub Codespaces (Linux)
; ============================================
default rel
global main
extern printf, scanf, getchar
section .data
   title db 10
         db "========================================",10
         db "       DUNGEON OF THE LOST KING",10
         db "========================================",10,0
   welcome_art db "                 / \",10
               db "                /   \",10
               db "               /_____\",10
               db "               | . . |",10
               db "               |  ^  |",10
               db "               |_____|",10
               db "             THE LOST KING",10,10,0
   name_prompt db "Enter your hero name (no spaces): ",0
   class_menu db 10,"Choose your character:",10
              db "[1] Warrior",10
              db "[2] Mage",10
              db "[3] Archer",10
              db "Choice: ",0
   warrior db "Warrior",0
   mage    db "Mage",0
   archer  db "Archer",0
   welcome_msg db 10,"Welcome, %s the %s!",10,0
   invalid_msg db "Invalid choice! Try again.",10,0
   main_menu db 10,"========== MAIN MENU ==========",10
             db "[1] Explore Dungeon",10
             db "[2] Character Status",10
             db "[3] Use Health Potion",10
             db "[4] View Inventory",10
             db "[5] Exit Game",10
             db "Choose: ",0
   goblin_art db 10
              db "          ,      ,",10
              db "         /(.-''-.)\",10
              db "         |\  /\  /|",10
              db "         | \(oo)/ |",10
              db "         \  /\  /",10
              db "          '----'",10
              db "        A GOBLIN APPEARS!",10,0
   chest_art db 10
             db "             __________",10
             db "            /________/|",10
             db "           |  GOLD?  | |",10
             db "           |________|/",10,0
   dragon_art db 10
              db "                     / \  //\",10
              db "            |\___/| /   \//  \\",10
              db "            /0  0  \      /    \",10
              db "           /     /  \____/      \",10
              db "           \_^_/\              /",10
              db "              THE DRAGON!",10,0
   room1_msg db 10,"ROOM 1: GOBLIN CHAMBER",10,0
   room2_msg db 10,"ROOM 2: TREASURE CHAMBER",10,0
   room3_msg db 10,"ROOM 3: DRAGON'S LAIR",10,0
   chest_menu db "[1] Open Chest (+50 gold)",10
              db "[2] Leave Chest",10
              db "Choice: ",0
   fight_menu db 10,"[1] Attack",10
               db "[2] Defend",10
               db "[3] Use Potion",10
               db "[4] Run",10
               db "Choose action: ",0
   enemy_status db "Enemy health: %d | Your health: %d",10,0
   attack_msg db "You attack for %d damage!",10,0
   hit_msg db "The enemy hits you for %d damage!",10,0
   defend_msg db "You defend against the next attack!",10,0
   defeated_msg db "Enemy defeated!",10,0
   run_msg db "You escaped and returned to the menu.",10,0
   potion_msg db "Potion used! Health restored by %d.",10,0
   potion_full db "Health is full. Potion consumed.",10,0
   no_potion db "You have no potions left!",10,0
   treasure_msg db "You found 50 gold!",10,0
   leave_msg db "You leave the chest behind.",10,0
   status_title db 10,"====== CHARACTER STATUS ======",10,0
   name_label db "Hero: %s",10,0
   class_label db "Class: %s",10,0
   health_label db "Health: %d / %d",10,0
   attack_label db "Attack: %d",10,0
   potion_label db "Potions: %d",10,0
   gold_label db "Gold: %d",10,0
   room_label db "Room: %d",10,0
   inventory_title db 10,"====== INVENTORY ======",10,0
   victory_msg db 10
               db "================================",10
               db "             VICTORY!",10
               db "  YOU DEFEATED THE DRAGON!",10
               db "  THE KINGDOM IS SAVED!",10
               db "================================",10,0
   gameover_msg db 10
                db "================================",10
                db "            GAME OVER",10
                db "      YOUR HERO HAS FALLEN",10
                db "================================",10,0
   exit_msg db "Thanks for playing!",10,0
   int_format db "%d",0
   name_format db "%63s",0
section .bss
   hero_name resb 64
   class_name resq 1
   choice resd 1
   health resd 1
   max_health resd 1
   attack resd 1
   potions resd 1
   gold resd 1
   room resd 1
   enemy_health resd 1
   enemy_damage resd 1
   defend resd 1
   battle_result resd 1
   heal_amount resd 1
section .text
; ============================================
; MAIN PROGRAM
; ============================================
main:
   push rbp
   mov rbp,rsp
   call display_welcome
   call get_player_info
   call initialize_character
main_loop:
   cmp dword [health],0
   jle game_over
   cmp dword [room],4
   je victory
   call display_main_menu
   call read_choice
   mov eax,[choice]
   cmp eax,1
   je explore
   cmp eax,2
   je status
   cmp eax,3
   je potion
   cmp eax,4
   je inventory
   cmp eax,5
   je exit_game
   lea rdi,[rel invalid_msg]
   xor eax,eax
   call printf
   jmp main_loop
explore:
   call explore_dungeon
   jmp main_loop
status:
   call display_status
   jmp main_loop
potion:
   call use_potion
   jmp main_loop
inventory:
   call display_inventory
   jmp main_loop
game_over:
   call display_game_result
   jmp exit_game
victory:
   call display_game_result
   jmp exit_game
exit_game:
   call exit_program
   xor eax,eax
   leave
   ret
; ============================================
; READ AND CHECK A NUMBER
; ============================================
read_choice:
   push rbp
   mov rbp,rsp
   lea rdi,[rel int_format]
   lea rsi,[rel choice]
   xor eax,eax
   call scanf
   cmp eax,1
   je .done
.clear_input:
   call getchar
   cmp eax,10
   je .invalid
   cmp eax,-1
   je .invalid
   jmp .clear_input
.invalid:
   mov dword [choice],-1
.done:
   leave
   ret
; ============================================
; PROCEDURE: display_welcome
; ============================================
display_welcome:
   push rbp
   mov rbp,rsp
   lea rdi,[rel title]
   xor eax,eax
   call printf
   lea rdi,[rel welcome_art]
   xor eax,eax
   call printf
   leave
   ret
; ============================================
; PROCEDURE: get_player_info
; ============================================
get_player_info:
   push rbp
   mov rbp,rsp
   lea rdi,[rel name_prompt]
   xor eax,eax
   call printf
   lea rdi,[rel name_format]
   lea rsi,[rel hero_name]
   xor eax,eax
   call scanf
.choose_class:
   lea rdi,[rel class_menu]
   xor eax,eax
   call printf
   call read_choice
   mov eax,[choice]
   cmp eax,1
   je .warrior
   cmp eax,2
   je .mage
   cmp eax,3
   je .archer
   lea rdi,[rel invalid_msg]
   xor eax,eax
   call printf
   jmp .choose_class
.warrior:
   lea rax,[rel warrior]
   mov [class_name],rax
   jmp .welcome
.mage:
   lea rax,[rel mage]
   mov [class_name],rax
   jmp .welcome
.archer:
   lea rax,[rel archer]
   mov [class_name],rax
.welcome:
   lea rdi,[rel welcome_msg]
   lea rsi,[rel hero_name]
   mov rdx,[class_name]
   xor eax,eax
   call printf
   leave
   ret
; ============================================
; PROCEDURE: initialize_character
; ============================================
initialize_character:
   push rbp
   mov rbp,rsp
   mov dword [gold],0
   mov dword [room],1
   mov dword [potions],2
   lea rax,[rel warrior]
   cmp [class_name],rax
   je .warrior
   lea rax,[rel mage]
   cmp [class_name],rax
   je .mage
   ; Archer
   mov dword [health],85
   mov dword [max_health],85
   mov dword [attack],25
   jmp .done
.warrior:
   mov dword [health],100
   mov dword [max_health],100
   mov dword [attack],20
   jmp .done
.mage:
   mov dword [health],70
   mov dword [max_health],70
   mov dword [attack],30
   mov dword [potions],3
.done:
   leave
   ret
; ============================================
; PROCEDURE: display_main_menu
; ============================================
display_main_menu:
   push rbp
   mov rbp,rsp
   lea rdi,[rel main_menu]
   xor eax,eax
   call printf
   leave
   ret
; ============================================
; PROCEDURE: explore_dungeon
; ============================================
explore_dungeon:
   push rbp
   mov rbp,rsp
   cmp dword [room],1
   je .goblin
   cmp dword [room],2
   je .treasure
   cmp dword [room],3
   je .dragon
   jmp .done
.goblin:
   lea rdi,[rel room1_msg]
   xor eax,eax
   call printf
   lea rdi,[rel goblin_art]
   xor eax,eax
   call printf
   mov dword [enemy_health],30
   mov dword [enemy_damage],10
   call battle_enemy
   cmp dword [battle_result],1
   jne .done
   mov dword [room],2
   jmp .done
.treasure:
   lea rdi,[rel room2_msg]
   xor eax,eax
   call printf
   lea rdi,[rel chest_art]
   xor eax,eax
   call printf
   lea rdi,[rel chest_menu]
   xor eax,eax
   call printf
   call read_choice
   cmp dword [choice],1
   je .open_chest
   cmp dword [choice],2
   je .leave_chest
   lea rdi,[rel invalid_msg]
   xor eax,eax
   call printf
   jmp .treasure
.open_chest:
   add dword [gold],50
   lea rdi,[rel treasure_msg]
   xor eax,eax
   call printf
   mov dword [room],3
   jmp .done
.leave_chest:
   lea rdi,[rel leave_msg]
   xor eax,eax
   call printf
   mov dword [room],3
   jmp .done
.dragon:
   lea rdi,[rel room3_msg]
   xor eax,eax
   call printf
   lea rdi,[rel dragon_art]
   xor eax,eax
   call printf
   mov dword [enemy_health],60
   mov dword [enemy_damage],15
   call battle_enemy
   cmp dword [battle_result],1
   jne .done
   mov dword [room],4
.done:
   leave
   ret
; ============================================
; PROCEDURE: battle_enemy
; ============================================
battle_enemy:
   push rbp
   mov rbp,rsp
   mov dword [battle_result],0
   mov dword [defend],0
.fight:
   cmp dword [health],0
   jle .dead
   cmp dword [enemy_health],0
   jle .win
   lea rdi,[rel enemy_status]
   mov esi,[enemy_health]
   mov edx,[health]
   xor eax,eax
   call printf
   lea rdi,[rel fight_menu]
   xor eax,eax
   call printf
   call read_choice
   cmp dword [choice],1
   je .attack
   cmp dword [choice],2
   je .defend
   cmp dword [choice],3
   je .potion
   cmp dword [choice],4
   je .run
   lea rdi,[rel invalid_msg]
   xor eax,eax
   call printf
   jmp .fight
.attack:
   mov eax,[attack]
   sub [enemy_health],eax
   lea rdi,[rel attack_msg]
   mov esi,[attack]
   xor eax,eax
   call printf
   cmp dword [enemy_health],0
   jle .win
   call enemy_attack
   jmp .fight
.defend:
   mov dword [defend],1
   lea rdi,[rel defend_msg]
   xor eax,eax
   call printf
   call enemy_attack
   jmp .fight
.potion:
   call use_potion
   jmp .fight
.run:
   lea rdi,[rel run_msg]
   xor eax,eax
   call printf
   mov dword [battle_result],0
   jmp .done
.dead:
   mov dword [battle_result],-1
   jmp .done
.win:
   lea rdi,[rel defeated_msg]
   xor eax,eax
   call printf
   mov dword [battle_result],1
.done:
   leave
   ret
; ============================================
; ENEMY ATTACK
; ============================================
enemy_attack:
   push rbp
   mov rbp,rsp
   mov eax,[enemy_damage]
   cmp dword [defend],1
   jne .hit
   sub eax,5
   cmp eax,0
   jge .reset_defend
   xor eax,eax
.reset_defend:
   mov dword [defend],0
.hit:
   sub [health],eax
   cmp dword [health],0
   jge .show_hit
   mov dword [health],0
.show_hit:
   lea rdi,[rel hit_msg]
   mov esi,eax
   xor eax,eax
   call printf
   leave
   ret
; ============================================
; PROCEDURE: use_potion
; ============================================
use_potion:
   push rbp
   mov rbp,rsp
   cmp dword [potions],0
   jle .none
   dec dword [potions]
   mov eax,[health]
   cmp eax,[max_health]
   jge .full
   mov ecx,[max_health]
   sub ecx,eax
   cmp ecx,20
   jle .heal
   mov ecx,20
.heal:
   add [health],ecx
   lea rdi,[rel potion_msg]
   mov esi,ecx
   xor eax,eax
   call printf
   jmp .done
.full:
   lea rdi,[rel potion_full]
   xor eax,eax
   call printf
   jmp .done
.none:
   lea rdi,[rel no_potion]
   xor eax,eax
   call printf
.done:
   leave
   ret
; ============================================
; PROCEDURE: display_status
; ============================================
display_status:
   push rbp
   mov rbp,rsp
   lea rdi,[rel status_title]
   xor eax,eax
   call printf
   lea rdi,[rel name_label]
   lea rsi,[rel hero_name]
   xor eax,eax
   call printf
   lea rdi,[rel class_label]
   mov rsi,[class_name]
   xor eax,eax
   call printf
   lea rdi,[rel health_label]
   mov esi,[health]
   mov edx,[max_health]
   xor eax,eax
   call printf
   lea rdi,[rel attack_label]
   mov esi,[attack]
   xor eax,eax
   call printf
   lea rdi,[rel potion_label]
   mov esi,[potions]
   xor eax,eax
   call printf
   lea rdi,[rel gold_label]
   mov esi,[gold]
   xor eax,eax
   call printf
   lea rdi,[rel room_label]
   mov esi,[room]
   xor eax,eax
   call printf
   leave
   ret
; ============================================
; PROCEDURE: display_inventory
; ============================================
display_inventory:
   push rbp
   mov rbp,rsp
   lea rdi,[rel inventory_title]
   xor eax,eax
   call printf
   lea rdi,[rel gold_label]
   mov esi,[gold]
   xor eax,eax
   call printf
   lea rdi,[rel potion_label]
   mov esi,[potions]
   xor eax,eax
   call printf
   leave
   ret
; ============================================
; PROCEDURE: display_game_result
; ============================================
display_game_result:
   push rbp
   mov rbp,rsp
   cmp dword [health],0
   jle .game_over
   lea rdi,[rel victory_msg]
   xor eax,eax
   call printf
   jmp .done
.game_over:
   lea rdi,[rel gameover_msg]
   xor eax,eax
   call printf
.done:
   leave
   ret
; ============================================
; PROCEDURE: exit_program
; ============================================
exit_program:
   push rbp
   mov rbp,rsp
   lea rdi,[rel exit_msg]
   xor eax,eax
   call printf
   leave
   ret