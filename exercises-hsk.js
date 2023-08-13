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

var dialogueMultipleMultipleChoiceQuestions = class dialogueMultipleMultipleChoiceQuestions {
  constructor() {
    this.idsForInputsIndex = 0
  }
  getNumberOfAlternatives() {
    // We assume that all exercises have the same number of
    // alternatives as the first exercise.
    //
    // We count those fields that are called "-label", but we could have
    // also counted for those that end with "-content".
    var anyExerciseNumber = this.exercisesToDisplay[0]['exerciseNumber']
    var regexpAlternativeData = new RegExp('^exercise-' + anyExerciseNumber + '-alternative-[0-9]+-label$')
    this.numberOfAlternatives = Object.entries(this.data)
      .filter((keyValue) => regexpAlternativeData.test(keyValue[0]))
      .length
  }
  getNode() {
    this.getNumberOfAlternatives()

    var node = document.createElement('div')

    var dialogue = document.createElement('div')
    dialogue.innerHTML = data['dialogue']
    if(this.cssClassDialogue)
      dialogue.classList.add(this.cssClassDialogue)

    var dialogueAudio = document.createElement('audio')
    dialogueAudio.setAttribute('controls', '')
    dialogueAudio.setAttribute('src', data['dialogue-audio'])

    node.appendChild(dialogueAudio)
    node.appendChild(dialogue)

    for(const exerciseToDisplay of this.exercisesToDisplay) {
      var exerciseContainer = document.createElement('div')
      if(this.cssClassExerciseContainer)
        exerciseContainer.classList.add(this.cssClassExerciseContainer)
      var prefixId = 'exercise-' + exerciseToDisplay['exerciseNumber'] + '-'

      var question = document.createElement('div')
      question.textContent = data[prefixId + 'question']

      var exerciseNumber = document.createElement('div')
      exerciseNumber.textContent = data[prefixId + 'number']

      var audio = document.createElement('audio')
      audio.setAttribute('controls', '')
      audio.setAttribute('src', data[prefixId + 'question-audio'])


      var alternativeContainerNode = document.createElement('div')
      alternativeContainerNode.classList.add('alternatives')

      for(var i=0; i<this.numberOfAlternatives; i++) {
        var alternativeDataName = prefixId + 'alternative-' + (i+1) + '-'
        var alternativeNode = document.createElement('div')
          alternativeNode.classList.add('alternative')
        var alternativeNodeLabel = document.createElement('div')
        alternativeNodeLabel.textContent = this.data[alternativeDataName + 'label']
        alternativeNodeLabel.classList.add('label')
        var alternativeNodeContent = document.createElement('div')
        alternativeNodeContent.textContent = this.data[alternativeDataName + 'content']
        alternativeNodeContent.classList.add('content')
        alternativeNode.appendChild(alternativeNodeLabel)
        alternativeNode.appendChild(alternativeNodeContent)
        alternativeContainerNode.appendChild(alternativeNode)
      }

      var input = document.createElement('input')
      input.type = 'text'
      input.id = this.exercisesToDisplay[this.idsForInputsIndex]['idForInput']
      this.idsForInputsIndex = this.idsForInputsIndex + 1

      exerciseContainer.appendChild(exerciseNumber)
      exerciseContainer.appendChild(question)
      exerciseContainer.appendChild(audio)
      exerciseContainer.appendChild(alternativeContainerNode)
      exerciseContainer.appendChild(input)
      node.appendChild(exerciseContainer)
    }
    return node
  }
}
