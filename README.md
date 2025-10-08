# Assembly-Memory-Management

&nbsp;&nbsp;&nbsp;Unfortunately the project is completely in romanian because it was a faculty project give in my first year.\
&nbsp;&nbsp;&nbsp;The project is about memory management in two cases, one where the memory is one-dimensional (a vector) or two-dimensional (a matrix). We had to implement functions such ass Add, Delete, Get, and Defragmentation.\
- *Add* -> we received a file name with a file size for which we had to fin a suitable continous section of our memory, if we didn't find then we won't add it.
- *Delete* -> we received a file name and cleared the memory of it.
- *Get* -> returns the memory portion of the file name.
- *Defragmentation* -> rearranges the memory so that there are no empty slots between two different files for example:
  - Before Defragmentation: 111000222
  - After Defragmentation: 111222000
