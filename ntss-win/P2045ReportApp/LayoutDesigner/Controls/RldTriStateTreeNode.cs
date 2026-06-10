using System.ComponentModel;
using System.Windows.Forms;

namespace LayoutDesigner
{
	/// <summary>
	/// ノード罫線タイプ
	/// </summary>
	internal enum NodeLineType
	{
		None,
		Straight,
		WithChildren
	}

	/// <summary>
	///	TriStateTreeNodeクラス
	/// </summary>
	public class RldTriStateTreeNode : TreeNode
	{
		private CheckState _nodeCheckState = CheckState.Unchecked;

		private bool _isContainer = false;
		private bool _checkboxVisible = true;

		// コンストラクタ
        /// <summary>
        /// TriStateTreeNodeクラス
        /// </summary>
		public RldTriStateTreeNode() : base() {}
        /// <summary>
        /// TriStateTreeNodeクラス
        /// </summary>
        /// <param name="text"></param>
		public RldTriStateTreeNode( string text ) : base( text ) {}
        /// <summary>
        /// TriStateTreeNodeクラス
        /// </summary>
        /// <param name="text"></param>
        /// <param name="imageIndex"></param>
        /// <param name="selectedImageIndex"></param>
		public RldTriStateTreeNode( string text, int imageIndex, int selectedImageIndex ) : base(text, imageIndex, selectedImageIndex) {}
        /// <summary>
        /// TriStateTreeNodeクラス
        /// </summary>
        /// <param name="text"></param>
        /// <param name="imageIndex"></param>
        /// <param name="selectedImageIndex"></param>
        /// <param name="children"></param>
		public RldTriStateTreeNode( string text, int imageIndex, int selectedImageIndex, RldTriStateTreeNode[] children ) : base(text, imageIndex, selectedImageIndex, children) {}
        /// <summary>
        /// TriStateTreeNodeクラス
        /// </summary>
        /// <param name="text"></param>
        /// <param name="children"></param>
		public RldTriStateTreeNode( string text, RldTriStateTreeNode[] children ) : base( text, children) {}


		/// <summary>
		/// チェックされているかを取得または設定します。
		/// </summary>
		[Browsable(false)]
		new public bool Checked
		{
			get { return (this._nodeCheckState != CheckState.Unchecked); }
			set { SetCheckedState( value ? CheckState.Checked: CheckState.Unchecked ); }
		}

		/// <summary>
		/// チェック状態を取得または設定します。
		/// </summary>
		public CheckState CheckState
		{
			get { return this._nodeCheckState; }
		}

		/// <summary>
		/// コンテナであるかを取得または設定します。
		/// </summary>
		public bool IsContainer
		{
			get { return _isContainer; } 
			set { _isContainer = value; }
		}

		/// <summary>
		/// チェックボックスを表示するかを取得または設定します。
		/// </summary>
		public bool CheckboxVisible
		{
			get { return this._checkboxVisible; }
			set { this._checkboxVisible = value; }
		}

		/// <summary>
		/// ノードの罫線タイプを取得
		/// </summary>
		internal NodeLineType NodeLineType
		{
			get 
			{
				if( null != this.TreeView )
				{
					if( !this.TreeView.ShowLines ) { return NodeLineType.None; }
					if( this.CheckboxVisible ) { return NodeLineType.None; }

					if( this.Nodes.Count > 0 )
					{
						return NodeLineType.WithChildren;
					}
					return NodeLineType.Straight;
				}

				return NodeLineType.None;
			}
		}

		/// <summary>
		/// チェック状態を設定
		/// </summary>
		/// <param name="value"></param>
		internal void SetCheckedState( CheckState value )
		{
			CheckStateChanged( _nodeCheckState, value ); 
		}

		/// <summary>
		/// 子ノードの状態が変更になった時の親ノードの状態変更
		/// </summary>
		/// <param name="childNewState">子ノードの新しい状態</param>
		private void ChildCheckStateChanged( CheckState childNewState )
		{
			bool notifyParent = false;
			CheckState currentState = this._nodeCheckState;
			CheckState newState = this._nodeCheckState;

			//	子ノードの状態で
			switch( childNewState )
			{
				case CheckState.Indeterminate: // child state changed to indeterminate
					// if one of the children's state changes to indeterminate, 
					// it's parent should do the same, if it is a container too!.
					if( IsContainer )
					{
						newState = CheckState.Indeterminate;

						// the same is valid for this node's parent.
						// check if this node's state has changed and inform the parent
						// if this is the case
						notifyParent = ( newState != currentState );
					}
					break;
				case CheckState.Checked:
					// One of the child nodes was checked so we must check:
					// 1) if the child node is the only child node, our state becomes checked too.
					// 2) if there are children with a state other then checked, our state
					//    must become indeterminate if this is a container.
					if( this.Nodes.Count == 1 ) // if there is only one child, our state changes too!
					{
						// set our state to checked too and set the flag for
						// parent notification. 
						newState = CheckState.Checked;
						notifyParent = true;
						break;
					}

					// set to checked by default
					// if this is not a container, there is no need to check further
					newState = CheckState.Checked;
					if( !IsContainer )
					{
						notifyParent = ( newState != currentState );
						break;
					}

					// traverse all child nodes to see if there are any with a state other then
					// checked. if so, change state to indeterminate.
					foreach( TreeNode node in this.Nodes )
					{
						RldTriStateTreeNode checkedNode = node as RldTriStateTreeNode;
						if( checkedNode != null && checkedNode.CheckState != CheckState.Checked  )
						{
							newState = CheckState.Indeterminate;
							break;
						}
					}

					// set notification flag if our state has to be changed too
					notifyParent = ( newState != currentState );
					break;
				case CheckState.Unchecked:
					// For nodes that are no containers, a child being unchecked is not relevant.
					// so we can exit at this point.
					if( !IsContainer )
						break;

					// A child's state has changed to unchecked so check:
					// 1) if this is the only child. if so, uncheck this node too, if it is a container, and set
					//	  notification flag for the parent.
					// 2) Check if there are child nodes with a state other then unchecked.
					//	  if so, change our state to indeterminate.
					if( this.Nodes.Count == 1 )
					{
						// synchronize state with only child.
						// set notification flag
						newState = CheckState.Unchecked;
						notifyParent = true;
						break;
					}
					
					// set to unchecked by default
					newState = CheckState.Unchecked;

					// if there is a child with a state other then unchecked,
					// our state must become indeterminate.
					foreach(TreeNode node in this.Nodes )
					{
						RldTriStateTreeNode checkedNode = node as RldTriStateTreeNode;
						if( checkedNode != null && checkedNode.CheckState != CheckState.Unchecked )
						{
							newState = CheckState.Indeterminate;
							break;
						}
					}

					// notify the parent only if our state is about to be changed too.
					notifyParent = ( newState != currentState );
					break;
			}

			// should we notify the parent? ( has our state changed? )
			if( notifyParent )
			{
				// change state
				this._nodeCheckState = newState;

				// notify parent
				if( this.Parent != null )
				{
					RldTriStateTreeNode parentNode = this.Parent as RldTriStateTreeNode;
					if( parentNode != null )
					{
						// call the same method on the parent.
						parentNode.ChildCheckStateChanged( this._nodeCheckState );
					}
				}
			}
		}

		/// <summary>
		/// チェック状態を変更する。
		/// </summary>
		/// <param name="oldState">前の状態</param>
		/// <param name="newState">新しい状態</param>
		private void CheckStateChanged( CheckState oldState, CheckState newState )
		{
			// 前の状態と新しい状態を比較
			if( newState != oldState )
			{
				// 前の状態と新しい状態が同じではない
				this._nodeCheckState = newState;

				// 子ノードが存在するかチェック
				if( this.Nodes != null && this.Nodes.Count > 0 )
				{
					// 子ノードが存在する場合は、子ノードにも適応
					foreach( TreeNode node in this.Nodes )
					{
						RldTriStateTreeNode tsNode = node as RldTriStateTreeNode;
						if( tsNode != null )
						{
							tsNode.ChangeChildState( newState );
						}
					}
				}

				//	親ノードが存在するかチェック
				if( this.Parent != null )
				{
					//	親ノードが存在する場合は、親ノードの状態も変更
					RldTriStateTreeNode parentNode = this.Parent as RldTriStateTreeNode;
					if( parentNode != null )
					{
						parentNode.ChildCheckStateChanged( this._nodeCheckState );
					}
				}
			}
		}

		/// <summary>
		/// 子ノードの状態を変更
		/// </summary>
		/// <param name="newState"></param>
		private void ChangeChildState( CheckState newState )
		{
			// 新しい状態に変更
			this._nodeCheckState = newState;

			//	この子ノードにも子ノードが存在するかチェック
			if( this.Nodes != null && this.Nodes.Count > 0 )
			{
				//	子ノードが存在する場合は、子ノードにも状態を適応
				foreach( TreeNode node in this.Nodes )
				{
					RldTriStateTreeNode tsNode = node as RldTriStateTreeNode;
					if( tsNode != null )
					{
						tsNode.ChangeChildState( newState );
					}
				}
			}
		}
	}
}
