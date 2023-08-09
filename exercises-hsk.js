function clearNodesWithIds(ids) {
  for(id of ids) {
    node = document.getElementById(id)
    if(node) {
      node.replaceChildren()
      node.remove()
    }
  }
}

function hideNodesInFrontCard(ids) {
  if(document.getElementById('back'))
    return
  for(id of ids) {
    node = document.getElementById(id)
    if(node)
      node.style.display = 'none'
  }
}

function compareInputAgainstMultipleAnswers(listOfIds) {
  for(const id of listOfIds) {
    // Get user input and show it
    var inputTextNodeId = id[0]
    var input = Persistence.getItem(inputTextNodeId)
    if(input)
      input = input.trim()
    var inputTextNode = document.getElementById(inputTextNodeId)
    setUserInputInInputTextFromFrontInBack([inputTextNodeId])
    // Store answers and remove nodes that contain them
    var answerNodeIds = id[1]
    var answers = []
    for(const id of answerNodeIds) {
      answers.push(document.getElementById(id).innerText)
    }
    clearNodesWithIds(answerNodeIds)
    // Check input against any of the answers
    var inputEqualsAnyAnswer = false
    for(const answer of answers) {
      if(input == answer) {
        inputEqualsAnyAnswer = true
        break
      }
    }
    // Highlight background
    if(!input)
      inputTextNode.classList.add('background-color-anki-incorrect-typed-answer')
    else if(!inputEqualsAnyAnswer)
      inputTextNode.classList.add('background-color-anki-incorrect-typed-answer')
    else
      inputTextNode.classList.add('background-color-anki-correct-typed-answer')
  }
}

function pauseLastAudioIfDefined() {
  if(typeof lastAudio !== 'undefined')
    lastAudio.pause()
}

function playFirstOrNextAudio() {
  var audio = new Audio(audios[index])
  audio.addEventListener('ended', playFirstOrNextAudio)
  audio.play()
  lastAudio = audio
  index = index + 1
}

function playAllAudiosFromTheBeginning() {
  pauseLastAudioIfDefined()
  index = 0
  playFirstOrNextAudio()
}

function indentEachParagraphInNodesWithIds(ids) {
  for(const id of ids) {
    var text = document.getElementById(id)
    var paragraphs = text.innerText.split(/\n+/)
    text.innerText = ''
    paragraphs.forEach((paragraph) => {
      node = document.createElement('div')
      node.textContent = paragraph
      text.appendChild(node)
      node.style.textAlign = 'left'
      node.style.textIndent = '30px'
    })
  }
}

function styleNumberedGapsInNodesWithIds(ids) {
  for(const id of ids) {
    node = document.getElementById(id)
    node.innerHTML = node.innerHTML.replace(
      /🟨(\d+)🟨/g,
      function(a, b) {
        var span = document.createElement('span')
        span.textContent = b;
        span.classList.add('gap');
        return span.outerHTML;
      }
    )
  }
}

function getAlternatives(alternatives, id) {
  // We create a container because the node that is contained uses
  // display: inline-block
  var container = document.createElement('div')
  var main = document.createElement('div')
  main.classList.add('exercises-hsk-group-of-alternatives')
  var counter = 65
  for(const alternative of alternatives) {
    var node = document.createElement('div')
    node.classList.add('exercises-hsk-alternative')
    var label = document.createElement('div')
    label.textContent = String.fromCharCode(counter) + '. '
    label.classList = 'label'
    var content = document.createElement('div')
    content.classList.add('content')
    content.textContent = alternative
    node.appendChild(label)
    node.appendChild(content)
    main.appendChild(node)
    counter = counter + 1
  }
  var input = document.createElement('input')
  input.type = 'text'
  input.id = id
  main.appendChild(input)
  container.appendChild(main)
  return container
}
