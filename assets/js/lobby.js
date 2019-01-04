let Lobby = {

  init(socket, element){
    if(!element) { return }
    socket.connect()
    socket.onError( resp => console.log("ERROR", resp) )
    socket.onClose( resp => console.log("CLOSE", resp) )
    let lobby = socket.channel("room:lobby")
    this.onReady(lobby)
  },

  onReady(lobby){
    let innInput         = document.querySelector("#inn-input")
    let historyContainer = document.querySelector("#history")
    let sendButton       = document.querySelector("#send")

    innInput.addEventListener("keypress", event => {
      if(event.keyCode === 13 && innInput.value != ""){
        this.push(lobby, innInput.value)
        innInput.value = ""
      }
    })

    sendButton.addEventListener("click", event => {
      if(event.button === 0 && innInput.value != ""){
        this.push(lobby, innInput.value)
        innInput.value = ""
      }
    })

    lobby.on("new_inn", payload => {
      this.renderInn(historyContainer, payload)
      this.cut_elements(historyContainer)
    })

    lobby.on("history", resp => {
      while (historyContainer.firstChild) {
        historyContainer.removeChild(historyContainer.firstChild)
      }
      resp.history.map(msg => {
        this.renderInns(historyContainer, msg)
      })
    })

    lobby.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
  
    lobby.onError(e => console.log("something went wrong", e))
    lobby.onClose(e => console.log("channel closed", e))
  },

  renderInn(historyContainer, msg) {
    let innItem = document.createElement("div");
    innItem.className = "row"
    innItem.innerText = `[${msg.time}] ${msg.inn} : ${msg.valid}`
    historyContainer.insertBefore(innItem, historyContainer.firstChild)
  },

  renderInns(historyContainer, msg){
    let innItem = document.createElement("div");
    innItem.className = "row"
    innItem.innerText = `[${msg.time}] ${msg.inn} : ${msg.valid}`
    historyContainer.appendChild(innItem)
  },

  push(lobby, value) {
    lobby.push("new_inn", {body: value})
      .receive("error", e => console.log(e))
      .receive("ok", e => console.log (e))
  },

  cut_elements(historyContainer) {
    Array.from(historyContainer.children).slice(10)
      .map(elem => historyContainer.removeChild(elem))
  },
}
export default Lobby